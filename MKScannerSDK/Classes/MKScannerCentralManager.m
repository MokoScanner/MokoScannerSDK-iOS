//
//  MKScannerCentralManager.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKScannerCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "MKBLESDKAdopter.h"
#import "CBPeripheral+MKBLEAdd.h"
#import "MKBLETaskOperation.h"

NSString *const mk_peripheralConnectStateChangedNotification = @"mk_peripheralConnectStateChangedNotification";
NSString *const mk_centralManagerStateChangedNotification = @"mk_centralManagerStateChangedNotification";

typedef NS_ENUM(NSInteger, currentManagerAction) {
    currentManagerActionDefault,
    currentManagerActionScan,
    currentManagerActionConnectPeripheral,
};

@interface NSObject (centralManager)

@end

@implementation NSObject (centralManager)

+ (void)load{
    [MKScannerCentralManager shared];
}

@end

static MKScannerCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKScannerCentralManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong)CBCentralManager *centralManager;

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, strong)dispatch_queue_t centralManagerQueue;

@property (nonatomic, copy)mk_connectFailedBlock connectFailBlock;

@property (nonatomic, copy)mk_connectSuccessBlock connectSucBlock;

@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, assign)mk_peripheralConnectStatus connectStatus;

@property (nonatomic, assign)mk_centralManagerState centralStatus;

@property (nonatomic, assign)currentManagerAction managerAction;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, assign)BOOL connectTimeout;

@property (nonatomic, assign)BOOL isConnecting;

@end

@implementation MKScannerCentralManager

- (instancetype)init {
    if (self = [super init]) {
        _centralManagerQueue = dispatch_queue_create("moko.com.centralManager", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_centralManagerQueue];
    }
    return self;
}

+ (MKScannerCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKScannerCentralManager new];
        }
    });
    return manager;
}

+ (void)attempDealloc {
    onceToken = 0;
    manager = nil;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    mk_centralManagerState managerState = mk_centralManagerStateUnable;
    if (central.state == CBCentralManagerStatePoweredOn) {
        managerState = mk_centralManagerStateEnable;
    }
    self.centralStatus = managerState;
    moko_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_centralManagerStateChangedNotification object:nil];
        if ([self.stateDelegate respondsToSelector:@selector(mk_centralStateChanged:)]) {
            [self.stateDelegate mk_centralStateChanged:managerState];
        }
    });
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    if (self.peripheral) {
        [self.peripheral setNil];
        self.peripheral = nil;
        [self.operationQueue cancelAllOperations];
    }
    if (self.connectStatus == mk_peripheralConnectStatusConnected) {
        [self updateManagerStateConnectState:mk_peripheralConnectStatusDisconnect];
    }
    if (self.managerAction == currentManagerActionDefault) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        self.managerAction = currentManagerActionDefault;
        [self.centralManager stopScan];
        moko_main_safe(^{
            if ([self.scanDelegate respondsToSelector:@selector(mk_centralStopScan)]) {
                [self.scanDelegate mk_centralStopScan];
            }
        });
        return;
    }
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    if ([RSSI integerValue] == 127) {
        return;
    }
    dispatch_async(_centralManagerQueue, ^{
        [self scanNewPeripheral:peripheral advDic:advertisementData rssi:RSSI];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if (self.connectTimeout) {
        return;
    }
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    [self.peripheral setNil];
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:@"FF19"]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    if (self.connectStatus != mk_peripheralConnectStatusConnected) {
        //如果是连接过程中发生的断开连接不处理
        return;
    }
    [self.peripheral setNil];
    self.peripheral = nil;
    [self updateManagerStateConnectState:mk_peripheralConnectStatusDisconnect];
    [self.operationQueue cancelAllOperations];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    if (self.connectTimeout) {
        return;
    }
    [self.peripheral setNil];
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FF19"]]) {
            //通用服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FF01"]]
                                     forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    if (self.connectTimeout) {
        return;
    }
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"FF19"]]) {
        return;
    }
    [self.peripheral updateCharacterWithService:service];
    if ([self.peripheral connectSuccess]) {
        //连接成功
        [self connectPeripheralSuccess];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        return;
    }
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKBLETaskOperation *operation in operations) {
            if (operation.executing) {
                [operation peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:NULL];
                break;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        return;
    }
    if (self.connectTimeout) {
        return;
    }
    [self.peripheral updateCurrentNotifySuccess:characteristic];
    if ([self.peripheral connectSuccess]) {
        //连接成功
        [self connectPeripheralSuccess];
    }
}

#pragma mark - ***********************public method************************
#pragma mark - scan method
- (BOOL)scanDevice{
    if (self.isConnecting) {
        return NO;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        return NO;
    }
    self.managerAction = currentManagerActionScan;
    if ([self.scanDelegate respondsToSelector:@selector(mk_centralStartScan)]) {
        moko_main_safe(^{
            [self.scanDelegate mk_centralStartScan];
        });
    }
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FF19"]] options:nil];
    return YES;
}

- (void)stopScan{
    if ([self.scanDelegate respondsToSelector:@selector(mk_centralStopScan)]) {
        moko_main_safe(^{
            [self.scanDelegate mk_centralStopScan];
        });
    }
    if (self.isConnecting) {
        //连接过程中不允许调用
        return;
    }
    [self.centralManager stopScan];
    self.managerAction = currentManagerActionDefault;
}

#pragma mark - connect method

- (void)connectPeripheral:(CBPeripheral *)peripheral
                 sucBlock:(mk_connectSuccessBlock)sucBlock
              failedBlock:(mk_connectFailedBlock)failedBlock{
    if (self.isConnecting) {
        [MKBLESDKAdopter operationConnectingErrorBlock:failedBlock];
        return;
    }
    self.isConnecting = YES;
    if (!peripheral) {
        self.isConnecting = NO;
        [MKBLESDKAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        self.isConnecting = NO;
        [MKBLESDKAdopter operationCentralBlePowerOffBlock:failedBlock];
        return;
    }
    [self.centralManager stopScan];
    __weak typeof(self) weakSelf = self;
    [self connectWithPeripheral:peripheral sucBlock:^(CBPeripheral *connectedPeripheral) {
        __strong typeof(self) sself = weakSelf;
        if (sucBlock) {
            sucBlock(connectedPeripheral);
        }
        [sself clearConnectBlock];
    } failedBlock:^(NSError *error) {
        __strong typeof(self) sself = weakSelf;
        if (failedBlock) {
            failedBlock(error);
        }
        [sself clearConnectBlock];
    }];
}

- (void)disconnectPeripheral{
    if (!self.peripheral || self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [self.peripheral setNil];
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    self.isConnecting = NO;
}

#pragma mark ****************************** task **********************************

- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
           characteristic:(CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
             successBlock:(mk_communicationSuccessBlock)successBlock
             failureBlock:(mk_communicationFailedBlock)failureBlock{
    MKBLETaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                            characteristic:characteristic
                                                                  resetNum:resetNum
                                                               commandData:commandData
                                                              successBlock:successBlock
                                                              failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)addTask:(MKBLETaskOperation *)task {
    if (!task) {
        return;
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:task];
    }
}

- (void)addNeedPartOfDataTaskWithTaskID:(mk_taskOperationID)operationID
                         characteristic:(CBCharacteristic *)characteristic
                            commandData:(NSString *)commandData
                           successBlock:(mk_communicationSuccessBlock)successBlock
                           failureBlock:(mk_communicationFailedBlock)failureBlock{
    MKBLETaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                            characteristic:characteristic
                                                                  resetNum:YES
                                                               commandData:commandData
                                                              successBlock:successBlock
                                                              failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)addNeedResetNumTaskWithTaskID:(mk_taskOperationID)operationID
                       characteristic:(CBCharacteristic *)characteristic
                               number:(NSInteger)number
                          commandData:(NSString *)commandData
                         successBlock:(mk_communicationSuccessBlock)successBlock
                         failureBlock:(mk_communicationFailedBlock)failureBlock{
    if (number < 1) {
        return;
    }
    MKBLETaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                            characteristic:characteristic
                                                                  resetNum:NO
                                                               commandData:commandData
                                                              successBlock:successBlock
                                                              failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL setNum = sel_registerName("setRespondCount:");
    NSString *numberString = [NSString stringWithFormat:@"%ld",(long)number];
    if ([operation respondsToSelector:setNum]) {
        ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)operation, setNum, numberString);
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

#pragma mark - ***************private method******************
#pragma mark - scan
- (void)scanNewPeripheral:(CBPeripheral *)peripheral advDic:(NSDictionary *)advDic rssi:(NSNumber *)rssi{
    if (self.managerAction == currentManagerActionDefault || !mk_validDict(advDic) || !peripheral) {
        return;
    }
    if (self.managerAction != currentManagerActionScan) {
        return;
    }
    NSString *deviceName = advDic[CBAdvertisementDataLocalNameKey];
    NSDictionary *dataDic = @{
                              @"deviceName":(deviceName ? deviceName : @""),
                              @"rssi":rssi,
                              @"peripheral":peripheral
                              };
    //扫描情况下
    if ([self.scanDelegate respondsToSelector:@selector(mk_centralDidDiscoverPeripheral:)]) {
        moko_main_safe(^{
            [self.scanDelegate mk_centralDidDiscoverPeripheral:dataDic];
        });
    }
}

#pragma mark - connect
- (void)connectWithPeripheral:(CBPeripheral *)peripheral
                     sucBlock:(mk_connectSuccessBlock)sucBlock
                  failedBlock:(mk_connectFailedBlock)failedBlock{
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        [self.operationQueue cancelAllOperations];
        [self.peripheral setNil];
    }
    self.peripheral = nil;
    self.peripheral = peripheral;
    self.managerAction = currentManagerActionConnectPeripheral;
    self.connectSucBlock = sucBlock;
    self.connectFailBlock = failedBlock;
    [self centralConnectPeripheral:peripheral];
}

- (void)centralConnectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        return;
    }
    [self.centralManager stopScan];
    [self updateManagerStateConnectState:mk_peripheralConnectStatusConnecting];
    [self initConnectTimer];
    [self.centralManager connectPeripheral:peripheral options:@{}];
}

- (void)initConnectTimer{
    self.connectTimeout = NO;
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_centralManagerQueue);
    dispatch_source_set_timer(self.connectTimer, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC),  20 * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.connectTimer, ^{
        weakSelf.connectTimeout = YES;
        [weakSelf connectPeripheralFailed];
    });
    dispatch_resume(self.connectTimer);
}

- (void)resetOriSettings{
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    self.managerAction = currentManagerActionDefault;
    self.connectTimeout = NO;
    self.isConnecting = NO;
}

- (void)connectPeripheralFailed{
    [self resetOriSettings];
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral.delegate = nil;
        [self.peripheral setNil];
    }
    self.peripheral = nil;
    [self updateManagerStateConnectState:mk_peripheralConnectStatusConnectedFailed];
    [MKBLESDKAdopter operationConnectFailedBlock:self.connectFailBlock];
}

- (void)connectPeripheralSuccess{
    if (self.connectTimeout) {
        return;
    }
    [self resetOriSettings];
    [self updateManagerStateConnectState:mk_peripheralConnectStatusConnected];
    moko_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock(self.peripheral);
        }
    });
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailBlock) {
        self.connectFailBlock = nil;
    }
}

- (void)updateManagerStateConnectState:(mk_peripheralConnectStatus)state{
    self.connectStatus = state;
    moko_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_peripheralConnectStateChangedNotification object:nil];
        if ([self.stateDelegate respondsToSelector:@selector(mk_peripheralConnectStateChanged:)]) {
            [self.stateDelegate mk_peripheralConnectStateChanged:state];
        }
    });
}

#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData characteristic:(CBCharacteristic *)characteristic{
    if (!self.peripheral
        || !mk_validStr(commandData)
        || !characteristic
        || self.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    NSData *data = [MKBLESDKAdopter stringToData:commandData];
    NSLog(@"发送的数据+++++++++++++++++++++++++++++++++>%@",data);
    if (!mk_validData(data)) {
        return;
    }
    [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (BOOL)canSendData{
    if (!self.peripheral) {
        return NO;
    }
    return (self.peripheral.state == CBPeripheralStateConnected);
}

- (MKBLETaskOperation *)generateOperationWithOperationID:(mk_taskOperationID)operationID
                                          characteristic:(CBCharacteristic *)characteristic
                                                resetNum:(BOOL)resetNum
                                             commandData:(NSString *)commandData
                                            successBlock:(mk_communicationSuccessBlock)successBlock
                                            failureBlock:(mk_communicationFailedBlock)failureBlock{
    if (![self canSendData]) {
        [MKBLESDKAdopter operationDisconnectedErrorBlock:failureBlock];
        return nil;
    }
    if (!mk_validStr(commandData)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failureBlock];
        return nil;
    }
    if (!characteristic) {
        [MKBLESDKAdopter operationCharacteristicErrorBlock:failureBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData characteristic:characteristic];
    } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
        if (error) {
            moko_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [MKBLESDKAdopter operationRequestDataErrorBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[mk_dataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[mk_dataInformation];
            if (!dataList) {
                [MKBLESDKAdopter operationRequestDataErrorBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            moko_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[mk_dataInformation],
                                    };
        moko_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end

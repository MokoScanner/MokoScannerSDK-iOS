//
//  MKAddDeviceDataManager.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceDataManager.h"

#import "MKConnectDeviceView.h"
#import "MKConnectDeviceProgressView.h"
#import "MKConnectDeviceWifiView.h"
#import "MKConnectViewProtocol.h"
#import "MKDeviceDataBaseManager.h"
#import "MKDeviceServerConfigDatabase.h"

#import "MKDeviceBLEConfigManager.h"

@interface MKAddDeviceDataManager()<MKConnectViewConfirmDelegate>

@property (nonatomic, copy)void (^completeBlock)(NSError *error, BOOL success, MKDeviceModel *deviceModel);

@property (nonatomic, copy)NSString *wifiSSID;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableArray *viewList;

/**
 超过15s没有接收到连接成功数据，则认为连接失败
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

@property (nonatomic, assign)BOOL connectTimeout;

@property (nonatomic, strong)MKDeviceBLEConfigManager *configManager;

@end

@implementation MKAddDeviceDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceDataManager销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (MKAddDeviceDataManager *)addDeviceManager{
    return [[self alloc] init];
}

#pragma mark - MKConnectViewConfirmDelegate
- (void)confirmButtonActionWithView:(UIView *)view returnData:(id)returnData{
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return;
    }
    if (view == self.viewList[0]) {
        //MKConnectDeviceWifiView
        if (!ValidDict(returnData)) {
            return;
        }
        self.wifiSSID = returnData[@"ssid"];
        self.password = returnData[@"password"];
        [self connectPlug];
        return;
    }
}

- (void)cancelButtonActionWithView:(UIView *)view{
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    self.completeBlock = nil;
}

#pragma mark - event method

#pragma mark - notification

- (void)receiveDeviceTopicData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic)
        || self.connectTimeout
        || ![deviceDic[@"id"] isEqualToString:self.serverModel.mqttID]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedDeviceKeepAliveStatusNotification object:nil];
    //当前设备已经连上mqtt服务器了
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
        self.receiveTimerCount = 0;
        self.connectTimeout = NO;
    }
    MKConnectDeviceProgressView *progressView = self.viewList[1];
    [progressView setProgress:1.f duration:0.2];
    [self performSelector:@selector(saveDeviceToLocal) withObject:nil afterDelay:0.5];
}

#pragma mark - public method

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    WS(weakSelf);
    [self connectProgressWithCompleteBlock:^(NSError *error, BOOL success, MKDeviceModel *deviceModel) {
        if (completeBlock) {
            completeBlock(error,success,deviceModel);
        }
        weakSelf.completeBlock = nil;
    }];
}

#pragma mark -
- (void)connectProgressWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    self.completeBlock = nil;
    self.completeBlock = completeBlock;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedDeviceKeepAliveStatusNotification object:nil];
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    [self.viewList removeAllObjects];
    [self loadViewList];
    //显示wifi设置页面
    [self showDeviceWifiView];
}

#pragma mark - SDK
- (void)connectPlug{
    MKConnectDeviceWifiView *wifiView = self.viewList[0];
    if ([MKScannerCentralManager shared].centralStatus == mk_centralManagerStateUnable) {
        [wifiView showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:wifiView isPenetration:NO];
    WS(weakSelf);
    [self.configManager configDeviceDataWithWifiSSID:self.wifiSSID wifiPassword:self.password peripheral:self.deviceParams[@"peripheral"] serverModel:self.serverModel sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf connectMQTTServer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
        [weakSelf dismisAllAlertView];
    }];
}

#pragma mark - private method
- (void)connectMQTTServer{
    //开始连接mqtt服务器
    NSString *subTopic = [MKMQTTServerDataManager sharedInstance].configServerModel.subscribedTopic;
    if (ValidStr(subTopic)) {
        //如果用户设置了app端的订阅topic，则直接订阅该topic
        [[MKMQTTServerManager sharedInstance] subscriptions:@[subTopic]];
    }else {
        [[MKMQTTServerManager sharedInstance] subscriptions:@[self.serverModel.publishedTopic]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceTopicData:)
                                                 name:MKMQTTServerReceivedDeviceKeepAliveStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self startConnectTimer];
    [self showProcessView];
}

- (void)startConnectTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 90.f) {
            //接受数据超时
            [weakSelf connectFailed];
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

- (void)connectFailed{
    self.receiveTimerCount = 0;
    self.connectTimeout = YES;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismisAllAlertView];
        NSError *error = [[NSError alloc] initWithDomain:@"addDeviceDataManager" code:-999 userInfo:@{@"errorInfo":@"Connect failed"}];
        if (self.completeBlock) {
            self.completeBlock(error, NO, nil);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedDeviceKeepAliveStatusNotification object:nil];
    });
}

- (void)saveDeviceToLocal{
    MKDeviceModel *dataModel = [[MKDeviceModel alloc] init];
    dataModel.device_name = self.deviceParams[@"deviceName"];
    dataModel.clientID = self.serverModel.clientId;
    dataModel.subscribedTopic = self.serverModel.subscribedTopic;
    dataModel.publishedTopic = self.serverModel.publishedTopic;
    dataModel.mqttID = self.serverModel.mqttID;
    CBPeripheral *peripheral = self.deviceParams[@"peripheral"];
    dataModel.deviceUUID = peripheral.identifier.UUIDString;
    WS(weakSelf);
    [MKDeviceDataBaseManager insertDeviceList:@[dataModel] sucBlock:^{
        [weakSelf saveDeviceMQTTServerConfig:dataModel];
    } failedBlock:^(NSError *error) {
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
    }];
}

- (void)saveDeviceMQTTServerConfig:(MKDeviceModel *)dataModel {
    WS(weakSelf);
    [MKDeviceServerConfigDatabase insertDeviceList:@[self.serverModel] sucBlock:^{
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(nil, YES, dataModel);
        }
    } failedBlock:^(NSError * _Nonnull error) {
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
    }];
}

#pragma mark - alertView

/**
 当前网络是plug ap wifi，需要用户输入周围可用的wifi给plug
 */
- (void)showDeviceWifiView{
    id <MKConnectViewProtocol>wifiView = self.viewList[0];
    [wifiView showConnectAlertView];
    id <MKConnectViewProtocol>progressView = self.viewList[1];
    [progressView dismiss];
}

/**
 开始连接流程
 */
- (void)showProcessView{
    id <MKConnectViewProtocol>wifiView = self.viewList[0];
    [wifiView dismiss];
    MKConnectDeviceProgressView *progressView = self.viewList[1];
    [progressView showConnectAlertView];
    [progressView setProgress:0.90 duration:90.f];
}

- (void)dismisAllAlertView{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        [view dismiss];
    }
}

- (void)loadViewList{
    MKConnectDeviceWifiView *wifiView = [[MKConnectDeviceWifiView alloc] init];
    wifiView.delegate = self;
    MKConnectDeviceProgressView *progressView = [[MKConnectDeviceProgressView alloc] init];
    progressView.delegate = self;
    [self.viewList addObject:wifiView];
    [self.viewList addObject:progressView];
}

#pragma mark - setter & getter
- (NSMutableArray *)viewList{
    if (!_viewList) {
        _viewList = [NSMutableArray arrayWithCapacity:2];
    }
    return _viewList;
}

- (MKDeviceBLEConfigManager *)configManager {
    if (!_configManager) {
        _configManager = [[MKDeviceBLEConfigManager alloc] init];
    }
    return _configManager;
}

@end

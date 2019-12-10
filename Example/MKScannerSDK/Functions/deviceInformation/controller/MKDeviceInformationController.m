//
//  MKDeviceInformationController.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInformationController.h"
#import "MKDeviceInformationCell.h"
#import "MKDeviceInformationModel.h"

@interface MKDeviceInformationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)dispatch_queue_t readDataQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKDeviceInformationController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceInformationController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Device Information";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self loadTableDatas];
    [self addNotifications];
    [self readDataFromDevice];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceInformationCell *cell = [MKDeviceInformationCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - Notification
- (void)receiveMQTTServerData:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    NSDictionary *dataDic = deviceDic[@"data"];
    if (!ValidDict(deviceDic) || !ValidDict(dataDic) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_companyNameKey]) {
        //公司名称
        MKDeviceInformationModel *companyModel = self.dataList[0];
        companyModel.rightMsg = dataDic[@"companyName"];
        [self readDataResult];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_dateOfProductionKey]) {
        //生产日期
        MKDeviceInformationModel *dateModel = self.dataList[1];
        dateModel.rightMsg = dataDic[@"dateOfProduction"];
        [self readDataResult];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_deviceProductModeKey]) {
        //产品型号
        MKDeviceInformationModel *productModel = self.dataList[2];
        productModel.rightMsg = dataDic[@"productMode"];
        [self readDataResult];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_firmwareVersionKey]) {
        //固件版本
        MKDeviceInformationModel *firmModel = self.dataList[3];
        firmModel.rightMsg = dataDic[@"firmware"];
        [self readDataResult];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_macAddressKey]) {
        //mac地址
        MKDeviceInformationModel *macModel = self.dataList[4];
        macModel.rightMsg = dataDic[@"macAddress"];
        [self readDataResult];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    dispatch_async(self.readDataQueue, ^{
        if (![self readCompanyName]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read company name error"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        if (![self readDateOfProduct]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read date of product error"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        if (![self readProductMode]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read product mode error"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        if (![self readFirmwareVersion]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read firmware version error"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        if (![self readMacAddress]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read mac address error"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        moko_dispatch_main_safe(^{
            [self initReadTimer];
        });
    });
}

- (BOOL)readCompanyName {
    __block BOOL success = NO;
    [MKMQTTServerInterface readCompanyNameWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDateOfProduct {
    __block BOOL success = NO;
    [MKMQTTServerInterface readDateOfManufactureWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readProductMode {
    __block BOOL success = NO;
    [MKMQTTServerInterface readProductModeWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readFirmwareVersion {
    __block BOOL success = NO;
    [MKMQTTServerInterface readFirmwareVersionWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMacAddress {
    __block BOOL success = NO;
    [MKMQTTServerInterface readDeviceMacAddressWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method

- (void)initReadTimer{
    self.readTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 30.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.readTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.readTimer, ^{
        weakSelf.readTimeout = YES;
        dispatch_cancel(weakSelf.readTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MKHudManager share] hide];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [weakSelf.view showCentralToast:@"Get data failed!"];
            [weakSelf performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
        });
    });
    dispatch_resume(self.readTimer);
}

- (void)readDataResult {
    if (![self readDataSuccess]) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MKHudManager share] hide];
}

- (BOOL)readDataSuccess {
    for (MKDeviceInformationModel *model in self.dataList) {
        if (!ValidStr(model.rightMsg)) {
            return NO;
        }
    }
    return YES;
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedCompanyNameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedDateOfProductionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedFirmwareVersionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedMacAddressNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedDeviceProductModeNotification
                                               object:nil];
}

- (void)loadTableDatas{
    MKDeviceInformationModel *companyModel = [[MKDeviceInformationModel alloc] init];
    companyModel.leftMsg = @"Company Name";
    [self.dataList addObject:companyModel];
    
    MKDeviceInformationModel *dateModel = [[MKDeviceInformationModel alloc] init];
    dateModel.leftMsg = @"Date of Manufacture";
    [self.dataList addObject:dateModel];
    
    MKDeviceInformationModel *nameModel = [[MKDeviceInformationModel alloc] init];
    nameModel.leftMsg = @"Product Model";
    [self.dataList addObject:nameModel];
    
    MKDeviceInformationModel *firmModel = [[MKDeviceInformationModel alloc] init];
    firmModel.leftMsg = @"Firmware Version";
    [self.dataList addObject:firmModel];
    
    MKDeviceInformationModel *macModel = [[MKDeviceInformationModel alloc] init];
    macModel.leftMsg = @"Device Mac";
    [self.dataList addObject:macModel];
    
    [self.tableView reloadData];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readDataQueue {
    if (!_readDataQueue) {
        _readDataQueue = dispatch_queue_create("mk_readDeviceInformationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readDataQueue;
}

@end

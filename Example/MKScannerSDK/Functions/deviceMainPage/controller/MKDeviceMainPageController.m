//
//  MKDeviceMainPageController.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/19.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceMainPageController.h"

#import "MKDeviceMainPageCell.h"
#import "MKDeviceMainPageIntervalView.h"

#import "MKDeviceInfoController.h"
#import "MKFilterConditionsController.h"

#import "MKDeviceDataBaseManager.h"

@interface MKDeviceMainPageController ()<UITableViewDelegate, UITableViewDataSource, MKDeviceMainPageIntervalViewDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIButton *scanStatusButton;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKDeviceMainPageIntervalView *intervalView;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@property (nonatomic, assign)NSInteger receiveDataCount;

@property (nonatomic, copy)NSString *intervalValue;

@property (nonatomic, assign)BOOL deviceUpdateFirmware;

@end

@implementation MKDeviceMainPageController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"MKDeviceMainPageController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    [self getDeviceLocalName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotification];
    [self readScanStatus];
    // Do any additional setup after loading the view.
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *pageModel = self.dataList[indexPath.row];
    return [MKDeviceMainPageCell fetchCellHeight:pageModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.scanStatusButton.selected) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.scanStatusButton.selected) {
        return 0;
    }
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKDeviceMainPageCell *cell = [MKDeviceMainPageCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - MKDeviceMainPageIntervalCellDelegate
- (void)saveIntervalTime:(NSString *)interval {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface configDeviceScanInterval:[interval integerValue] topic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        self.intervalValue = interval;
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - NSNotification method
- (void)receiveMQTTServerData:(NSNotification *)note {
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    NSDictionary *dataDic = deviceDic[@"data"];
    if (!ValidDict(deviceDic) || !ValidDict(dataDic) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_bluetoothStatusKey]) {
        //蓝牙开关状态
        self.scanStatusButton.selected = ([dataDic[@"status"] isEqualToString:@"01"]);
        [self reloadScanButtonStatus];
        self.receiveDataCount ++;
        [self dataReceiveSuccess];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_bluetoothScanTimeLengthKey]) {
        //蓝牙扫描时长
        if (ValidStr(dataDic[@"interval"])) {
            self.intervalView.textField.text = dataDic[@"interval"];
            self.intervalValue = dataDic[@"interval"];
        }
        self.receiveDataCount ++;
        [self dataReceiveSuccess];
        return;
    }
}

- (void)receiveBroadcastData:(NSNotification *)note {
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    NSArray *dataList = deviceDic[@"data"];
    if (!ValidDict(deviceDic) || !ValidArray(dataList) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    
    if (self.dataList.count == 0) {
        [self.dataList addObjectsFromArray:dataList];
    }else {
        [self.dataList insertObjects:dataList atIndex:0];
    }
    if (!self.scanStatusButton.selected) {
        //关闭了开关，列表隐藏刷新无效
        return;
    }
    self.intervalView.totalLabel.text = [NSString stringWithFormat:@"total:%ld",(long)self.dataList.count];
    [self.tableView reloadData];
}

- (void)deviceIsOffline:(NSNotification *)note {
    if (self.deviceUpdateFirmware) {
        //升级过程中不处理离线
        return;
    }
    NSString *mqttID = note.userInfo[@"mqttID"];
    if (!ValidStr(mqttID) || ![mqttID isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)deviceStartUpdateFirmware:(NSNotification *)note {
    NSString *mqttID = note.userInfo[@"mqttID"];
    if (!ValidStr(mqttID) || ![mqttID isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    self.deviceUpdateFirmware = YES;
}

- (void)deviceStopUpdateFirmware:(NSNotification *)note {
    NSString *mqttID = note.userInfo[@"mqttID"];
    if (!ValidStr(mqttID) || ![mqttID isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    self.deviceUpdateFirmware = NO;
}

#pragma mark - event method
- (void)editFilterButtonPressed {
    MKFilterConditionsController *vc = [[MKFilterConditionsController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanStatusButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface configDeviceScanStatus:!self.scanStatusButton.selected topic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.dataList removeAllObjects];
        self.intervalView.totalLabel.text = [NSString stringWithFormat:@"total:%ld",(long)self.dataList.count];
        self.scanStatusButton.selected = !self.scanStatusButton.selected;
        [self reloadScanButtonStatus];
        if (self.scanStatusButton.isSelected) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveBroadcastData:)
                                                         name:MKMQTTServerReceivedBleBroadcastDataNotification
                                                       object:nil];
        }else {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MKMQTTServerReceivedBleBroadcastDataNotification
                                                          object:nil];
        }
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readScanStatus {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readDeviceScanStatusWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self performSelector:@selector(readScanInterval) withObject:nil afterDelay:1.f];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readScanInterval {
    [MKMQTTServerInterface readDeviceScanIntervalWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self initReadTimer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 数据库操作
- (void)getDeviceLocalName{
    [MKDeviceDataBaseManager selectLocalNameWithMQTTID:self.deviceModel.mqttID sucBlock:^(NSString *localName) {
        self.deviceModel.device_name = localName;
        self.titleLabel.text = localName;
    } failedBlock:^(NSError *error) {
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark -
- (void)reloadScanButtonStatus {
    if (!self.scanStatusButton.selected) {
        //未打开
        [self.scanStatusButton setImage:LOADIMAGE(@"deviceList_switchStateOffIcon", @"png") forState:UIControlStateNormal];
        [self.tableView reloadData];
        [self.intervalView setHidden:YES];
        return;
    }
    //打开
    if (ValidStr(self.intervalValue)) {
        self.intervalView.textField.text = self.intervalValue;
    }
    [self.scanStatusButton setImage:LOADIMAGE(@"deviceList_switchStateOnIcon", @"png") forState:UIControlStateNormal];
    [self.tableView reloadData];
    [self.intervalView setHidden:NO];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBluetoothStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBluetoothScanTimeLengthNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceIsOffline:)
                                                 name:MKDeviceOfflineNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceStartUpdateFirmware:)
                                                 name:MKStartUpdateDeviceFirmwareNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceStopUpdateFirmware:)
                                                 name:MKStopUpdateDeviceFirmwareNotification
                                               object:nil];
}

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

- (void)dataReceiveSuccess {
    if (self.receiveDataCount < 2) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    if (self.scanStatusButton.isSelected) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveBroadcastData:)
                                                     name:MKMQTTServerReceivedBleBroadcastDataNotification
                                                   object:nil];
    }
    [[MKHudManager share] hide];
    self.rightButton.enabled = YES;
}

#pragma mark - UI
- (void)loadSubViews {
    self.titleLabel.text = self.deviceModel.device_name;
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    self.rightButton.enabled = NO;
    self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
    UIView *headerView = [self headerView];
    [self.view addSubview:headerView];
    [self.view addSubview:self.intervalView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.intervalView.mas_bottom).mas_offset(1.f);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)scanStatusButton {
    if (!_scanStatusButton) {
        _scanStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanStatusButton setImage:LOADIMAGE(@"deviceList_switchStateOffIcon", @"png") forState:UIControlStateNormal];
        [_scanStatusButton addTapAction:self selector:@selector(scanStatusButtonPressed)];
    }
    return _scanStatusButton;
}

- (MKDeviceMainPageIntervalView *)intervalView {
    if (!_intervalView) {
        _intervalView = [[MKDeviceMainPageIntervalView alloc] initWithFrame:CGRectMake(0, (defaultTopInset + 100.f), kScreenWidth, 70.f)];
        _intervalView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        _intervalView.delegate = self;
    }
    return _intervalView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, defaultTopInset, kScreenWidth, 100.f)];
    headerView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 10.f, kScreenWidth - 30.f, 40.f)];
    buttonView.backgroundColor = COLOR_WHITE_MACROS;
    buttonView.layer.masksToBounds = YES;
    buttonView.layer.cornerRadius = 6.f;
    [buttonView addTapAction:self selector:@selector(editFilterButtonPressed)];
    [headerView addSubview:buttonView];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 9.f, 22.f, 22.f)];
    icon.image = LOADIMAGE(@"deviceMainPage_searchIcon", @"png");
    [buttonView addSubview:icon];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.f, (40.f - MKFont(16.f).lineHeight) / 2, 150.f, MKFont(16.f).lineHeight)];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = UIColorFromRGB(0xd9d9d9);
    msgLabel.text = @"Edit Filter";
    [buttonView addSubview:msgLabel];
    
    UILabel *scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 95.f - 10.f - 25.f, 100.f, 25.f)];
    scanLabel.textColor = DEFAULT_TEXT_COLOR;
    scanLabel.textAlignment = NSTextAlignmentLeft;
    scanLabel.font = MKFont(16.f);
    scanLabel.text = @"Scan";
    [headerView addSubview:scanLabel];
    
    self.scanStatusButton.frame = CGRectMake(kScreenWidth - 15.f - 45.f, 95.f - 10.f - 25.f, 45.f, 25.f);
    [headerView addSubview:self.scanStatusButton];
    
    return headerView;
}

@end

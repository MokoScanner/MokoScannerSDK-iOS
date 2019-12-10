//
//  MKDeviceListController.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceListController.h"
#import "MKConfigServerModel.h"
#import "MKDeviceListCell.h"
#import "MKAddDeviceView.h"
#import "EasyLodingView.h"

#import "MKDeviceDataBaseManager.h"

#import "MKConfigServerAppController.h"
#import "MKScanDeviceController.h"
#import "MKAboutController.h"

#import "MKDeviceMainPageController.h"

@interface MKDeviceListController ()<UITableViewDelegate, UITableViewDataSource, MKDeviceModelDelegate, MKDeviceListCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKAddDeviceView *addDeviceView;

@property (nonatomic, strong)UIView *loadingView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)UIView *dataView;

@end

@implementation MKDeviceListController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceListController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotification];
    [self performSelector:@selector(mqttServerManagerStateChanged) withObject:nil afterDelay:2.f];
    [self getDeviceList];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法

- (void)leftButtonMethod{
    MKConfigServerAppController *vc = [[MKConfigServerAppController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod{
    MKAboutController *vc = [[MKAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceListCell *cell = [MKDeviceListCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell resetFlagForFrame];
    return cell;
}

#pragma mark - MKDeviceModelDelegate
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel{
    if (!deviceModel) {
        return;
    }
    [self updateDeviceModelState:YES stateDic:@{@"id":SafeStr(deviceModel.mqttID)}];
}

#pragma mark - MKMQTTServerManagerStateChangedDelegate
- (void)mqttServerManagerStateChanged{
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
        //网络不可用
        [EasyLodingView hidenLoingInView:self.loadingView];
        self.titleLabel.text = @"Network unavailable";
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnecting) {
        //正在连接
        [EasyLodingView showLodingText:@"Connecting..." config:^EasyLodingConfig *{
            EasyLodingConfig *config = [EasyLodingConfig shared];
            config.lodingType = LodingShowTypeIndicatorLeft;
            config.textFont = MKFont(18.f);
            config.bgColor = UIColorFromRGB(0x0188cc);
            config.tintColor = COLOR_WHITE_MACROS;
            config.superView = self.loadingView;
            return config;
        }];
        return;
    }
    [EasyLodingView hidenLoingInView:self.loadingView];
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnected) {
        //连接成功
        self.titleLabel.text = @"MokoScanner";
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateError) {
        //连接出错
        self.titleLabel.text = @"Connect error";
        return;
    }
//    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateError) {
//        //连接出错
//        [self.view showCentralToast:@"Connect MQTT Server error"];
//    }
    
}

#pragma mark - MKDeviceListCellDelegate
- (void)cellSelected:(NSIndexPath *)path {
    BOOL canNext = [self cellCanSelected];
    if (!canNext) {
        return;
    }
    MKDeviceModel *dataModel = self.dataList[path.row];
    if (dataModel.plugState == MKBLEGatewayOffline) {
        [self.view showCentralToast:@"Device is off-line!"];
        return;
    }
    MKDeviceMainPageController *vc = [[MKDeviceMainPageController alloc] init];
    vc.deviceModel = dataModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cellDeleteButtonPressed:(NSIndexPath *)path{
    [MKCommonMethod deleteDeviceWithModel:self.dataList[path.row] target:self reset:NO];
}

/**
 重新设置cell的子控件位置，主要是删除按钮方面的处理
 */
- (void)cellResetFrame{
    [self cellCanSelected];
}

#pragma mark - event method
- (void)addButtonPressed {
    if (![[MKMQTTServerDataManager sharedInstance].configServerModel needParametersHasValue]) {
        //如果app的mqtt服务器信息没有，则去设置
        MKConfigServerAppController *vc = [[MKConfigServerAppController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    //如果都有了，则去添加设备
    MKScanDeviceController *vc = [[MKScanDeviceController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification Method

- (void)receiveDeviceOnlineStatus:(NSNotification *)note {
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic)) {
        return;
    }
    [self updateDeviceModelState:NO stateDic:deviceDic];
}

#pragma mark - get device list
- (void)getDeviceList{
    [MKDeviceDataBaseManager getLocalDeviceListWithSucBlock:^(NSArray<MKDeviceModel *> *deviceList) {
        [self processLocalDeviceDatas:deviceList];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)processLocalDeviceDatas:(NSArray<MKDeviceModel *> *)deviceList{
    if (!ValidArray(deviceList)) {
        //如果本地没有，则加载添加设备页面，
        [self.view sendSubviewToBack:self.dataView];
        [self.view bringSubviewToFront:self.addDeviceView];
        [self reloadTableViewWithData:@[]];
        return;
    }
    //如果本地有设备，显示设备列表
    [self.view sendSubviewToBack:self.addDeviceView];
    [self.view bringSubviewToFront:self.dataView];
    [self reloadTableViewWithData:deviceList];
}

- (void)reloadTableViewWithData:(NSArray <MKDeviceModel *> *)deviceList{
    //页面消失需要取消model的定时器
    for (MKDeviceModel *model in self.dataList) {
        [model cancel];
    }
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:deviceList];
    [self.tableView reloadData];
    for (MKDeviceModel *model in self.dataList) {
        model.delegate = self;
        [model startStateMonitoringTimer];
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected
        && [MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnecting) {
        [[MKMQTTServerDataManager sharedInstance] connectServer];
    }
    [self resetMQTTServerTopic];
}

- (void)resetMQTTServerTopic{
    if (!ValidArray(self.dataList)) {
        return;
    }
    NSMutableArray *topicList = [NSMutableArray arrayWithCapacity:self.dataList.count];
    for (MKDeviceModel *deviceModel in self.dataList) {
        [topicList addObject:[deviceModel currentPublishedTopic]];
    }
    [[MKMQTTServerManager sharedInstance] subscriptions:topicList];
}

#pragma mark -
- (void)updateDeviceModelState:(BOOL)offline stateDic:(NSDictionary *)stateDic{
    @synchronized(self) {
        //需要执行的代码
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            for (NSInteger i = 0; i < self.dataList.count; i ++) {
                MKDeviceModel *model = self.dataList[i];
                if ([model.mqttID isEqualToString:stateDic[@"id"]]) {
                    model.plugState = (offline ? MKBLEGatewayOffline : MKBLEGatewayOnline);
                    [model resetTimerCounter];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (offline) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:MKDeviceOfflineNotification
                                                                                object:nil
                                                                              userInfo:@{@"mqttID":SafeStr(model.mqttID)}];
                        }
                        if ([self visibleCell:i]) {
                            [UIView performWithoutAnimation:^{
                                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            }];
                        }
                    });
                    break;
                }
            }
        });
    }
}

#pragma mark -
/**
 当有cell右侧的删除按钮出现时，不能触发点击事件
 
 @return YES可点击，NO不可点击
 */
- (BOOL)cellCanSelected{
    BOOL canSelected = YES;
    NSArray *arrCells = [self.tableView visibleCells];
    for (NSInteger i = 0; i < [arrCells count]; i++) {
        MKDeviceListCell *cell = arrCells[i];
        if ([cell isKindOfClass:[MKDeviceListCell class]] && [cell canReset]) {
            [cell resetCellFrame];
            canSelected = NO;
        }
    }
    return canSelected;
}

- (BOOL)visibleCell:(NSInteger)row {
    NSArray *arrCells = [self.tableView visibleCells];
    BOOL visible = NO;
    for (NSInteger i = 0; i < [arrCells count]; i++) {
        MKDeviceListCell *cell = arrCells[i];
        if ([cell isKindOfClass:[MKDeviceListCell class]] && cell.indexPath.row == row) {
            visible = YES;
        }
    }
    return visible;
}

#pragma mark -

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(mqttServerManagerStateChanged)
                                       name:MKNetworkStatusChangedNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(getDeviceList)
                                       name:MKNeedReadDataFromLocalNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(mqttServerManagerStateChanged)
                                       name:MKMQTTSessionManagerStateChangedNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOnlineStatus:)
                                                 name:MKMQTTServerReceivedDeviceKeepAliveStatusNotification
                                               object:nil];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.leftButton setImage:LOADIMAGE(@"mokoLife_menuIcon", @"png") forState:UIControlStateNormal];
    [self.rightButton setImage:LOADIMAGE(@"scanRightAboutIcon", @"png") forState:UIControlStateNormal];
    self.titleLabel.text = @"MokoScanner";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.titleLabel addSubview:self.loadingView];
    [self.view addSubview:self.addDeviceView];
    [self.view addSubview:self.dataView];
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(-5.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-5.f);
    }];
    [self.addDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self.dataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self.view sendSubviewToBack:self.addDeviceView];
}

#pragma mark - setter & getter
- (MKAddDeviceView *)addDeviceView{
    if (!_addDeviceView) {
        _addDeviceView = [[MKAddDeviceView alloc] init];
        _addDeviceView.backgroundColor = COLOR_WHITE_MACROS;
        WS(weakSelf);
        _addDeviceView.addDeviceBlock = ^{
            [weakSelf addButtonPressed];
        };
    }
    return _addDeviceView;
}

- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
    }
    return _loadingView;
}

- (UIView *)dataView {
    if (!_dataView) {
        _dataView = [[UIView alloc] init];
        _dataView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        [_dataView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-100.f);
        }];
        
        UIButton *addButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Add Devices"
                                                                       target:self
                                                                       action:@selector(addButtonPressed)];
        [_dataView addSubview:addButton];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(58.f);
            make.right.mas_equalTo(-58.f);
            make.bottom.mas_equalTo(-30.f);
            make.height.mas_equalTo(50.f);
        }];
    }
    return _dataView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end

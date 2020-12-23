//
//  MKFilterConditionsController.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterConditionsController.h"

#import "MKFilterNormalCell.h"
#import "MKFilterRawDataCell.h"
#import "MKFilterRawMsgCell.h"

#import "MKFilterRawDataCellModel.h"
#import "MKFilterNormalCellModel.h"
#import "MKFilterDataModel.h"

#import "MKSlider.h"

static NSInteger const statusOnHeight = 85.f;
static NSInteger const statusOffHeight = 44.f;

@interface MKFilterConditionsController ()<UITableViewDelegate, UITableViewDataSource, MKFilterNormalCellDelegate, MKFilterRawMsgCellDelegate,MKFilterRawDataCellDelegate>

@property (nonatomic, strong)MKSlider *rssiSlider;

@property (nonatomic, strong)UILabel *rssiValueLabel;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)MKFilterDataModel *filterDataModel;

@property (nonatomic, strong)UIButton *confirmButton;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@property (nonatomic, assign)NSInteger receiveDataCount;

@end

@implementation MKFilterConditionsController

- (void)dealloc {
    NSLog(@"MKFilterConditionsController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSection0Datas];
    [self addNotifications];
    [self readScanFilteringRssi];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadRowHeightWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return 1;
    }
    return (self.filterDataModel.filterRawDataIsOn ? self.section2List.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKFilterNormalCell *cell = [MKFilterNormalCell initCellWithTableView:tableView];
        cell.delegate = self;
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 1) {
        MKFilterRawMsgCell *cell = [MKFilterRawMsgCell initCellWithTableView:tableView];
        cell.filterIsOn = self.filterDataModel.filterRawDataIsOn;
        cell.delegate = self;
        return cell;
    }
    MKFilterRawDataCell *cell = [MKFilterRawDataCell initCellWithTableView:tableView];
    cell.dataModel = self.section2List[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark - MKFilterNormalCellDelegate
- (void)fliterSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //name filter
        self.filterDataModel.nameFilterIsOn = isOn;
    }else if (index == 1) {
        //mac filter
        self.filterDataModel.macFilterIsOn = isOn;
    }
    MKFilterNormalCellModel *dataModel = self.section0List[index];
    dataModel.isOn = isOn;
    [self.tableView reloadRow:index inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)filterContent:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        //name filter
        self.filterDataModel.nameFilter = newValue;
    }else if (index == 1) {
        //mac filter
        self.filterDataModel.macFilter = newValue;
    }
    MKFilterNormalCellModel *dataModel = self.section0List[index];
    dataModel.textFieldValue = newValue;
}

#pragma mark - MKFilterRawMsgCellDelegate
- (void)filterRawDataStatusChanged:(BOOL)isOn {
    self.filterDataModel.filterRawDataIsOn = isOn;
    [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addFilterRawDataConditions {
    if (!self.filterDataModel.filterRawDataIsOn) {
        return;
    }
    [self addButtonPressed];
}

- (void)subFilterRawDataConditions {
    if (!self.filterDataModel.filterRawDataIsOn) {
        return;
    }
    [self subButtonPressed];
}

#pragma mark - MKFilterRawDataCellDelegate
/// 输入框内容发生改变
/// @param textType 哪个输入框发生改变了
/// @param index 当前cell所在的row
/// @param textValue 当前textField内容
- (void)rawFilterDataChanged:(mk_filterRawDataCellTextType)textType
                       index:(NSInteger)index
                   textValue:(NSString *)textValue {
    if (index >= self.section2List.count) {
        return;
    }
    MKFilterRawDataCellModel *model = self.section2List[index];
    if (textType == mk_filterRawDataCellTextTypeDataType) {
        model.dataType = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeMinIndex) {
        model.minIndex = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeMaxIndex) {
        model.maxIndex = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeRawDataType) {
        model.rawData = textValue;
    }
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
    if ([deviceDic[@"function"] isEqualToString:mk_bleFilteringRssiKey]) {
        //过滤的rssi
        self.rssiSlider.value = [dataDic[@"rssi"] floatValue];
        [self sliderValueChanged];
        [self readDataIsSuccess];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_bleFilteringDeviceNameKey]) {
        //过滤的设备名称
        self.filterDataModel.nameFilter = dataDic[@"filterName"];
        self.filterDataModel.nameFilterIsOn = ValidStr(dataDic[@"filterName"]);
        MKFilterNormalCellModel *nameModel = self.section0List[0];
        nameModel.isOn = ValidStr(dataDic[@"filterName"]);
        nameModel.textFieldValue = dataDic[@"filterName"];
        [self readDataIsSuccess];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_deviceRawFilterKey]) {
        //过滤的蓝牙数据
        NSArray *list = dataDic[@"filterList"];
        self.filterDataModel.filterRawDataIsOn = (list.count > 0);
        for (NSInteger i = 0; i < list.count; i ++) {
            NSDictionary *dic = list[i];
            MKFilterRawDataCellModel *model = [[MKFilterRawDataCellModel alloc] init];
            [model modelSetWithJSON:dic];
            [self.section2List addObject:model];
        }
        [self readDataIsSuccess];
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_deviceMacFilterKey]) {
        //读取过滤蓝牙mac地址
        self.filterDataModel.macFilter = dataDic[@"macFilter"];
        self.filterDataModel.macFilterIsOn = ValidStr(dataDic[@"macFilter"]);
        MKFilterNormalCellModel *macModel = self.section0List[1];
        macModel.isOn = ValidStr(dataDic[@"macFilter"]);
        macModel.textFieldValue = dataDic[@"macFilter"];
        [self readDataIsSuccess];
        return;
    }
}

#pragma mark - event method
- (void)sliderValueChanged {
    NSString *valueString = [NSString stringWithFormat:@"%.f",self.rssiSlider.value];
    self.rssiValueLabel.text = [valueString stringByAppendingString:@"dBm"];
    self.filterDataModel.filterRssi = [valueString integerValue];
}

- (void)subButtonPressed {
    if (self.section2List.count == 0) {
        [self.view showCentralToast:@"There are currently no filters to delete"];
        return;
    }
    NSString *msg = @"Please confirm whether to delete  a filter option，If yes，the last option will be deleted.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteRawDataFilterDatas];
    }];
    [alertController addAction:moreAction];
    
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)addButtonPressed {
    if (self.section2List.count >= 5) {
        [self.view showCentralToast:@"You can set up to 5 filters!"];
        return;
    }
    MKFilterRawDataCellModel *dataModel = [[MKFilterRawDataCellModel alloc] init];
    [self.section2List addObject:dataModel];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)confirmButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.filterDataModel configDataWithRawConditons:self.section2List mqttID:self.deviceModel.mqttID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Success"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readScanFilteringRssi {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readDeviceScanFilteringRssiWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self performSelector:@selector(readScanFilteringName) withObject:nil afterDelay:1.f];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readScanFilteringName {
    [MKMQTTServerInterface readDeviceScanFilteringNameWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self performSelector:@selector(readMacFilterDatas) withObject:nil afterDelay:1.f];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readMacFilterDatas {
    [MKMQTTServerInterface readDeviceMacFilterDataWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self performSelector:@selector(readRawFilterDatas) withObject:nil afterDelay:1.f];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readRawFilterDatas {
    [MKMQTTServerInterface readDeviceRawFilterDataWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self initReadTimer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (CGFloat)loadRowHeightWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //name filter
            return (self.filterDataModel.nameFilterIsOn ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 1) {
            //mac filter
            return (self.filterDataModel.macFilterIsOn ? statusOnHeight : statusOffHeight);
        }
    }
    if (indexPath.section == 1) {
        return 44.f;
    }
    return 95.f;
}

- (void)loadSection0Datas {
    MKFilterNormalCellModel *nameModel = [[MKFilterNormalCellModel alloc] init];
    nameModel.msg = @"Name Filter";
    nameModel.textPlaceholder = @"1~29 Characters";
    nameModel.textFieldType = normalInput;
    nameModel.maxLength = 29;
    nameModel.index = 0;
    [self.section0List addObject:nameModel];
    
    MKFilterNormalCellModel *macModel = [[MKFilterNormalCellModel alloc] init];
    macModel.msg = @"MAC Filter";
    macModel.textPlaceholder = @"6 Bytes";
    macModel.textFieldType = hexCharOnly;
    macModel.maxLength = 12;
    macModel.index = 1;
    [self.section0List addObject:macModel];
}

- (void)deleteRawDataFilterDatas {
    if (self.section2List.count < 1) {
        return;
    }
    [self.section2List removeLastObject];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedRawFilterNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBleFilteringRssiNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBleFilteringDeviceNameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedMacFilterNotification
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

- (void)readDataIsSuccess {
    self.receiveDataCount ++;
    if (self.receiveDataCount < 4) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MKHudManager share] hide];
    [self.tableView reloadData];
}

#pragma mark - UI

- (void)loadSubViews {
    self.titleLabel.text = self.deviceModel.device_name;
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(239, 239, 239);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self tableHeaderView];
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

- (MKFilterDataModel *)filterDataModel {
    if (!_filterDataModel) {
        _filterDataModel = [[MKFilterDataModel alloc] init];
    }
    return _filterDataModel;
}

- (MKSlider *)rssiSlider {
    if (!_rssiSlider) {
        _rssiSlider = [[MKSlider alloc] init];
        _rssiSlider.maximumValue = 0;
        _rssiSlider.minimumValue = -100;
        _rssiSlider.value = 0;
        [_rssiSlider addTarget:self
                        action:@selector(sliderValueChanged)
              forControlEvents:UIControlEventValueChanged];
    }
    return _rssiSlider;
}

- (UILabel *)rssiValueLabel {
    if (!_rssiValueLabel) {
        _rssiValueLabel = [[UILabel alloc] init];
        _rssiValueLabel.textColor = DEFAULT_TEXT_COLOR;
        _rssiValueLabel.textAlignment = NSTextAlignmentLeft;
        _rssiValueLabel.font = MKFont(13.f);
        _rssiValueLabel.text = @"0dBm";
    }
    return _rssiValueLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Done"
                                                                  target:self
                                                                  action:@selector(confirmButtonPressed)];
    }
    return _confirmButton;
}

- (UIView *)tableHeaderView {
    CGFloat headerViewHeight = 60.f;
    CGFloat valueLabelWidth = 60.f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, headerViewHeight)];
    headerView.backgroundColor = RGBCOLOR(239, 239, 239);
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 5.f, kScreenWidth - 2 * 15, MKFont(15.f).lineHeight)];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.attributedText = [MKAttributedString getAttributedString:@[@"RSSI Filter",@" (-100dBm~0dBm)"] fonts:@[MKFont(15.f),MKFont(13.f)] colors:@[DEFAULT_TEXT_COLOR, RGBCOLOR(129, 121, 140)]];
    [headerView addSubview:msgLabel];
    
    [headerView addSubview:self.rssiSlider];
    self.rssiSlider.frame = CGRectMake(15.f, headerViewHeight - 5.f - 20.f, kScreenWidth - 2 * 15 - valueLabelWidth - 5.f, 20.f);
    [headerView addSubview:self.rssiValueLabel];
    self.rssiValueLabel.frame = CGRectMake(kScreenWidth - 15.f - valueLabelWidth, headerViewHeight - 5.f - 20.f, valueLabelWidth, 20.f);
    return headerView;
}

- (UIView *)tableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100.f)];
    footerView.backgroundColor = RGBCOLOR(239, 239, 239);
    [footerView addSubview:self.confirmButton];
    self.confirmButton.frame = CGRectMake(30.f, 25.f, kScreenWidth - 2 * 30.f, 50.f);
    return footerView;
}

@end

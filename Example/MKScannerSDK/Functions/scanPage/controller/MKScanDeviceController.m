//
//  MKScanDeviceController.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKScanDeviceController.h"

#import "MKScanDeviceCell.h"
#import "MKScanDeviceModel.h"

#import "MKConfigServerDeviceController.h"

static NSString *const MKLeftButtonAnimationKey = @"MKLeftButtonAnimationKey";

@interface MKScanDeviceController ()<UITableViewDelegate,UITableViewDataSource,mk_scanPeripheralDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIImageView *circleIcon;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)dispatch_source_t scanTimer;

@end

@implementation MKScanDeviceController

- (void)dealloc {
    NSLog(@"MKScanDeviceController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    if ([MKScannerCentralManager shared].centralStatus != mk_centralManagerStateEnable) {
//        return;
//    }
//    self.rightButton.selected = NO;
//    [self rightButtonMethod];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [MKScannerCentralManager shared].scanDelegate = self;
    [self showCentralStatus];
    // Do any additional setup after loading the view.
}

#pragma mark - super method
- (void)rightButtonMethod {
    if ([MKScannerCentralManager shared].centralStatus != mk_centralManagerStateEnable) {
        [self.view showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    self.rightButton.selected = !self.rightButton.selected;
    if (!self.rightButton.isSelected) {
        //停止扫描
        [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
        [[MKScannerCentralManager shared] stopScan];
        if (self.scanTimer) {
            dispatch_cancel(self.scanTimer);
        }
        return;
    }
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    //刷新顶部设备数量
    [self addAnimationForLeftButton];
    [self scanTimerRun];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKScanDeviceModel *deviceModel = self.dataList[indexPath.row];
    MKConfigServerDeviceController *vc = [[MKConfigServerDeviceController alloc] init];
    vc.deviceParams = @{
                        @"peripheral":deviceModel.peripheral,
                        @"deviceName":deviceModel.deviceName,
                        };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKScanDeviceCell *cell = [MKScanDeviceCell initCellWithTableView:self.tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - mk_scanPeripheralDelegate
- (void)mk_centralStartScan {
    NSLog(@"开始扫描");
}

- (void)mk_centralDidDiscoverPeripheral:(NSDictionary *)dataDic {
    if (!ValidDict(dataDic)) {
        return;
    }
    MKScanDeviceModel *deviceModel = [[MKScanDeviceModel alloc] init];
    [deviceModel modelSetWithJSON:dataDic];
    @synchronized (self.dataList) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"peripheral == %@", deviceModel.peripheral];
        NSArray *array = [self.dataList filteredArrayUsingPredicate:predicate];
        if (!ValidArray(array)) {
            [self.dataList addObject:deviceModel];
            [self.tableView insertRow:(self.dataList.count - 1) inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)mk_centralStopScan {
    NSLog(@"停止扫描");
    if (self.rightButton.isSelected) {
        [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
        [self.rightButton setSelected:NO];
    }
}

#pragma mark - private method
- (void)showCentralStatus{
    if (kSystemVersion >= 11.0 && [MKScannerCentralManager shared].centralStatus != mk_centralManagerStateEnable) {
        //对于iOS11以上的系统，打开app的时候，如果蓝牙未打开，弹窗提示，后面系统蓝牙状态再发生改变就不需要弹窗了
        NSString *msg = @"The current system of bluetooth is not available!";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:moreAction];
        
        [kAppRootController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self rightButtonMethod];
}

- (void)addAnimationForLeftButton{
    [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
    [self.circleIcon.layer addAnimation:[self animation] forKey:MKLeftButtonAnimationKey];
}

- (CABasicAnimation *)animation{
    CABasicAnimation *transformAnima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnima.duration = 2.f;
    transformAnima.fromValue = @(0);
    transformAnima.toValue = @(2 * M_PI);
    transformAnima.autoreverses = NO;
    transformAnima.repeatCount = MAXFLOAT;
    transformAnima.removedOnCompletion = NO;
    return transformAnima;
}

#pragma mark - 扫描监听
- (void)scanTimerRun{
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[MKScannerCentralManager shared] scanDevice];
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [[MKScannerCentralManager shared] stopScan];
        dispatch_cancel(weakSelf.scanTimer);
    });
    dispatch_resume(self.scanTimer);
    
}

#pragma mark - UI
- (void)loadSubViews {
    self.titleLabel.text = @"Add Device";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton addSubview:self.circleIcon];
    [self.circleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.rightButton.mas_centerX);
        make.width.mas_equalTo(22.f);
        make.centerY.mas_equalTo(self.rightButton.mas_centerY);
        make.height.mas_equalTo(22.f);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIImageView *)circleIcon{
    if (!_circleIcon) {
        _circleIcon = [[UIImageView alloc] init];
        _circleIcon.image = LOADIMAGE(@"scanRefresh", @"png");
    }
    return _circleIcon;
}

@end

//
//  MKDeviceServerController.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/23.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceServerController.h"
#import "MKDeviceInformationCell.h"
#import "MKDeviceInformationModel.h"

#import "MKDeviceServerConfigDatabase.h"

@interface MKDeviceServerController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKDeviceServerController

- (void)dealloc {
    NSLog(@"MKDeviceServerController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableViewDatas];
    [self readServerModelFromSource];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MKDeviceInformationCell fetchCurrentCellHeight:self.dataList[indexPath.row]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKDeviceInformationCell *cell = [MKDeviceInformationCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - interface
- (void)readServerModelFromSource {
    
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKDeviceServerConfigDatabase selecteDeviceServerConfigWithMQTTID:self.deviceModel.mqttID sucBlock:^(MKConfigServerModel * _Nonnull serverModel) {
        [[MKHudManager share] hide];
        [self updateTableDatasWithServerModel:serverModel];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)updateTableDatasWithServerModel:(MKConfigServerModel *)configServerModel {
    
    MKDeviceInformationModel *hostModel = self.dataList[0];
    hostModel.rightMsg = configServerModel.host;
    
    MKDeviceInformationModel *portModel = self.dataList[1];
    portModel.rightMsg = configServerModel.port;
    
    MKDeviceInformationModel *cleanSessionModel = self.dataList[2];
    cleanSessionModel.rightMsg = (configServerModel.cleanSession ? @"ON" : @"OFF");
    
    MKDeviceInformationModel *userNameModel = self.dataList[3];
    userNameModel.rightMsg = configServerModel.userName;
    
    MKDeviceInformationModel *passwordModel = self.dataList[4];
    passwordModel.rightMsg = configServerModel.password;
    
    MKDeviceInformationModel *qosModel = self.dataList[5];
    qosModel.rightMsg = configServerModel.qos;
    
    MKDeviceInformationModel *keepAliveModel = self.dataList[6];
    keepAliveModel.rightMsg = configServerModel.keepAlive;
    
    MKDeviceInformationModel *clientIDModel = self.dataList[7];
    clientIDModel.rightMsg = configServerModel.clientId;
    
    MKDeviceInformationModel *deviceIDModel = self.dataList[8];
    deviceIDModel.rightMsg = configServerModel.mqttID;
    
    MKDeviceInformationModel *connectModeModel = self.dataList[9];
    connectModeModel.rightMsg = @"TCP";
    if (configServerModel.connectMode == 1) {
        connectModeModel.rightMsg = @"One-way SSL";
    }else if (configServerModel.connectMode == 2) {
        connectModeModel.rightMsg = @"Two-way SSL";
    }
    
    MKDeviceInformationModel *subTopicModel = self.dataList[10];
    subTopicModel.rightMsg = configServerModel.subscribedTopic;
    
    MKDeviceInformationModel *publishedTopicModel = self.dataList[11];
    publishedTopicModel.rightMsg = configServerModel.publishedTopic;
    
    [self.tableView reloadData];
}


- (void)loadTableViewDatas {
    MKDeviceInformationModel *hostModel = [[MKDeviceInformationModel alloc] init];
    hostModel.leftMsg = @"Host";
    [self.dataList addObject:hostModel];
    
    MKDeviceInformationModel *portModel = [[MKDeviceInformationModel alloc] init];
    portModel.leftMsg = @"Port";
    [self.dataList addObject:portModel];
    
    MKDeviceInformationModel *cleanSessionModel = [[MKDeviceInformationModel alloc] init];
    cleanSessionModel.leftMsg = @"Clean Session";
    [self.dataList addObject:cleanSessionModel];
    
    MKDeviceInformationModel *userNameModel = [[MKDeviceInformationModel alloc] init];
    userNameModel.leftMsg = @"Username";
    [self.dataList addObject:userNameModel];
    
    MKDeviceInformationModel *passwordModel = [[MKDeviceInformationModel alloc] init];
    passwordModel.leftMsg = @"Password";
    [self.dataList addObject:passwordModel];
    
    MKDeviceInformationModel *qosModel = [[MKDeviceInformationModel alloc] init];
    qosModel.leftMsg = @"Qos";
    [self.dataList addObject:qosModel];
    
    MKDeviceInformationModel *keepAliveModel = [[MKDeviceInformationModel alloc] init];
    keepAliveModel.leftMsg = @"Keep Alive";
    [self.dataList addObject:keepAliveModel];
    
    MKDeviceInformationModel *clientIDModel = [[MKDeviceInformationModel alloc] init];
    clientIDModel.leftMsg = @"Client Id";
    [self.dataList addObject:clientIDModel];
    
    MKDeviceInformationModel *deviceIDModel = [[MKDeviceInformationModel alloc] init];
    deviceIDModel.leftMsg = @"Device Id";
    [self.dataList addObject:deviceIDModel];
    
    MKDeviceInformationModel *connectModeModel = [[MKDeviceInformationModel alloc] init];
    connectModeModel.leftMsg = @"Connect mode";
    [self.dataList addObject:connectModeModel];
    
    MKDeviceInformationModel *subTopicModel = [[MKDeviceInformationModel alloc] init];
    subTopicModel.leftMsg = @"Subscribed Topic";
    [self.dataList addObject:subTopicModel];
    
    MKDeviceInformationModel *publishedTopicModel = [[MKDeviceInformationModel alloc] init];
    publishedTopicModel.leftMsg = @"Published Topic";
    [self.dataList addObject:publishedTopicModel];
    
    [self.tableView reloadData];
}

#pragma mark -
- (void)loadSubViews {
    self.titleLabel.text = @"MQTT settings for device";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
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

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end

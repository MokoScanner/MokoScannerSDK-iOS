//
//  MKLEDSettingController.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKLEDSettingController.h"

@interface MKLEDSettingModel : NSObject<MKLEDSettingProtocol>

@property (nonatomic, assign)BOOL serverConnectingIson;

@property (nonatomic, assign)BOOL serverConnectedIson;

@property (nonatomic, assign)BOOL bleBroadcastIson;

@property (nonatomic, assign)BOOL bleConnectingIson;

@end

@implementation MKLEDSettingModel

@end

@interface MKLEDSettingController ()

@property (nonatomic, strong)UIView *broadcastView;

@property (nonatomic, strong)UIImageView *broadcastIcon;

@property (nonatomic, strong)UIView *bleConnectedView;

@property (nonatomic, strong)UIImageView *bleConnectedIcon;

@property (nonatomic, strong)UIView *wifiConnectingView;

@property (nonatomic, strong)UIImageView *wifiConnectingIcon;

@property (nonatomic, strong)UIView *serverConnectedView;

@property (nonatomic, strong)UIImageView *serverConnectedIcon;

@property (nonatomic, strong)MKLEDSettingModel *settingModel;

@property (nonatomic, strong)UIButton *confirmButton;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKLEDSettingController

- (void)dealloc {
    NSLog(@"MKLEDSettingController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MKMQTTServerReceivedLEDSettingNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedLEDSettingNotification
                                               object:nil];
    [self readLEDSettings];
}

#pragma mark - note
- (void)receiveMQTTServerData:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    NSDictionary *dataDic = deviceDic[@"data"];
    if (!ValidDict(deviceDic) || !ValidDict(dataDic) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_deviceLEDSettingKey]) {
        self.settingModel.bleBroadcastIson = [dataDic[@"bleBroadcastIson"] boolValue];
        self.settingModel.bleConnectingIson = [dataDic[@"bleConnectingIson"] boolValue];
        self.settingModel.serverConnectingIson = [dataDic[@"serverConnectingIson"] boolValue];
        self.settingModel.serverConnectedIson = [dataDic[@"serverConnectedIson"] boolValue];
        [self reloadSettingStatus];
        if (self.readTimer) {
            dispatch_cancel(self.readTimer);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[MKHudManager share] hide];
        return;
    }
}

#pragma mark - event method
- (void)broadcastViewPressed {
    self.settingModel.bleBroadcastIson = !self.settingModel.bleBroadcastIson;
    [self reloadSettingStatus];
}

- (void)bleConnectedViewPressed {
    self.settingModel.bleConnectingIson = !self.settingModel.bleConnectingIson;
    [self reloadSettingStatus];
}

- (void)wifiConnectingViewPressed {
    self.settingModel.serverConnectingIson = !self.settingModel.serverConnectingIson;
    [self reloadSettingStatus];
}

- (void)serverConnectedViewPressed {
    self.settingModel.serverConnectedIson = !self.settingModel.serverConnectedIson;
    [self reloadSettingStatus];
}

- (void)confirmButtonPressed {
    [MKMQTTServerInterface configLEDSettings:self.settingModel topic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readLEDSettings {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readDeviceLEDSettingWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [self initReadTimer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
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

#pragma mark -
- (void)reloadSettingStatus {
    self.broadcastIcon.image = (self.settingModel.bleBroadcastIson ?
                                LOADIMAGE(@"configServer_ConnectMode_selected", @"png")
                                : LOADIMAGE(@"configServer_ConnectMode_normal", @"png"));
    self.bleConnectedIcon.image = (self.settingModel.bleConnectingIson ?
                                   LOADIMAGE(@"configServer_ConnectMode_selected", @"png")
                                   : LOADIMAGE(@"configServer_ConnectMode_normal", @"png"));
    self.wifiConnectingIcon.image = (self.settingModel.serverConnectingIson ?
                                     LOADIMAGE(@"configServer_ConnectMode_selected", @"png")
                                     : LOADIMAGE(@"configServer_ConnectMode_normal", @"png"));
    self.serverConnectedIcon.image = (self.settingModel.serverConnectedIson ?
                                      LOADIMAGE(@"configServer_ConnectMode_selected", @"png")
                                      : LOADIMAGE(@"configServer_ConnectMode_normal", @"png"));
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.view.backgroundColor = RGBCOLOR(239, 239, 239);
    self.defaultTitle = @"LED Settings";
    [self.rightButton setHidden:YES];
    
    [self.view addSubview:self.broadcastView];
    [self.broadcastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 40.f);
        make.height.mas_equalTo(44.f);
    }];
    [self.view addSubview:self.bleConnectedView];
    [self.bleConnectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.broadcastView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(44.f);
    }];
    [self.view addSubview:self.wifiConnectingView];
    [self.wifiConnectingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.bleConnectedView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(44.f);
    }];
    [self.view addSubview:self.serverConnectedView];
    [self.serverConnectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.wifiConnectingView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(44.f);
    }];
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(self.serverConnectedView.mas_bottom).mas_offset(60.f);
        make.height.mas_equalTo(50.f);
    }];
}

#pragma mark - getter
- (UIView *)broadcastView {
    if (!_broadcastView) {
        _broadcastView = [self loadViewWithImageView:self.broadcastIcon msg:@"Enable LED when bluetooth broadcasting"];
        [_broadcastView addTapAction:self selector:@selector(broadcastViewPressed)];
    }
    return _broadcastView;
}

- (UIImageView *)broadcastIcon {
    if (!_broadcastIcon) {
        _broadcastIcon = [[UIImageView alloc] init];
        _broadcastIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        _broadcastIcon.userInteractionEnabled = YES;
    }
    return _broadcastIcon;
}

- (UIView *)bleConnectedView {
    if (!_bleConnectedView) {
        _bleConnectedView = [self loadViewWithImageView:self.bleConnectedIcon msg:@"Enable LED when bluetooth connected"];
        [_bleConnectedView addTapAction:self selector:@selector(bleConnectedViewPressed)];
    }
    return _bleConnectedView;
}

- (UIImageView *)bleConnectedIcon {
    if (!_bleConnectedIcon) {
        _bleConnectedIcon = [[UIImageView alloc] init];
        _bleConnectedIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        _bleConnectedIcon.userInteractionEnabled = YES;
    }
    return _bleConnectedIcon;
}

- (UIView *)wifiConnectingView {
    if (!_wifiConnectingView) {
        _wifiConnectingView = [self loadViewWithImageView:self.wifiConnectingIcon msg:@"Enable LED when WIFI and server connecting"];
        [_wifiConnectingView addTapAction:self selector:@selector(wifiConnectingViewPressed)];
    }
    return _wifiConnectingView;
}

- (UIImageView *)wifiConnectingIcon {
    if (!_wifiConnectingIcon) {
        _wifiConnectingIcon = [[UIImageView alloc] init];
        _wifiConnectingIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        _wifiConnectingIcon.userInteractionEnabled = YES;
    }
    return _wifiConnectingIcon;
}

- (UIView *)serverConnectedView {
    if (!_serverConnectedView) {
        _serverConnectedView = [self loadViewWithImageView:self.serverConnectedIcon msg:@"Enable LED when server connected"];
        [_serverConnectedView addTapAction:self selector:@selector(serverConnectedViewPressed)];
    }
    return _serverConnectedView;
}

- (UIImageView *)serverConnectedIcon {
    if (!_serverConnectedIcon) {
        _serverConnectedIcon = [[UIImageView alloc] init];
        _serverConnectedIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        _serverConnectedIcon.userInteractionEnabled = YES;
    }
    return _serverConnectedIcon;
}

- (MKLEDSettingModel *)settingModel {
    if (!_settingModel) {
        _settingModel = [[MKLEDSettingModel alloc] init];
    }
    return _settingModel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Confirm"
                                                                  target:self
                                                                  action:@selector(confirmButtonPressed)];
    }
    return _confirmButton;
}

- (UIView *)loadViewWithImageView:(UIImageView *)imageView msg:(NSString *)msg {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGBCOLOR(239, 239, 239);
    
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(13.f);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.height.mas_equalTo(13.f);
    }];
    
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.text = msg;
    [view addSubview:msgLabel];
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageView.mas_right).mas_offset(2.f);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(view.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    
    return view;
}

@end

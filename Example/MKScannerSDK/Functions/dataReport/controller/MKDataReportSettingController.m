//
//  MKDataReportSettingController.m
//  MKBLEGateway
//
//  Created by aa on 2020/8/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDataReportSettingController.h"

@interface MKDataReportSettingController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *texdtField;

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

@implementation MKDataReportSettingController

- (void)dealloc {
    NSLog(@"MKDataReportSettingController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDataReportSettings];
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
    if ([deviceDic[@"function"] isEqualToString:mk_deviceDataReportTimeKey]) {
        if (self.readTimer) {
            dispatch_cancel(self.readTimer);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[MKHudManager share] hide];
        [self.texdtField setText:SafeStr(dataDic[@"time"])];
        return;
    }
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (!ValidStr(self.texdtField.text) || [self.texdtField.text integerValue] < 0 || [self.texdtField.text integerValue] > 60) {
        [self.view showCentralToast:@"Params Error"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface configDeviceDataReportSettingTime:[self.texdtField.text integerValue] topic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readDataReportSettings {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readDeviceDataReportSettingTimeWithTopic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerData:)
                                                     name:MKMQTTServerReceivedDataReportTimeNotification
                                                   object:nil];
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

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.view.backgroundColor = RGBCOLOR(239, 239, 239);
    self.defaultTitle = @"Data Report Setting";
    [self.rightButton setHidden:YES];
    [self.view addSubview:self.msgLabel];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.view addSubview:self.texdtField];
    [self.texdtField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(45.f);
        make.right.mas_equalTo(-45.f);
        make.top.mas_equalTo(self.texdtField.mas_bottom).mas_offset(100.f);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.text = @"Data Report Interval (Unit: 50ms)";
    }
    return _msgLabel;
}

- (UITextField *)texdtField {
    if (!_texdtField) {
        _texdtField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _texdtField.maxLength = 2;
        _texdtField.textColor = DEFAULT_TEXT_COLOR;
        _texdtField.font = MKFont(15.f);
        _texdtField.textAlignment = NSTextAlignmentLeft;
        _texdtField.backgroundColor = COLOR_WHITE_MACROS;
    }
    return _texdtField;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Confirm"
                                                                  target:self
                                                                  action:@selector(confirmButtonPressed)];
    }
    return _confirmButton;
}

@end

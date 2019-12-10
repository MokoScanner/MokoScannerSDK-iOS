//
//  MKEditFilterController.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKEditFilterController.h"

#import "MKSlider.h"

@interface MKEditFilterController ()

@property (nonatomic, strong)UILabel *rssiLabel;

@property (nonatomic, strong)MKSlider *rssiSlider;

@property (nonatomic, strong)UILabel *rssiValueLabel;

@property (nonatomic, strong)UILabel *filterNameLabel;

@property (nonatomic, strong)UITextField *filterTextField;

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

@implementation MKEditFilterController

#pragma mark - life circle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"MKEditFilterController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotifications];
    [self readScanFilteringRssi];
    // Do any additional setup after loading the view.
}

#pragma mark - super method

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
        self.receiveDataCount ++;
        if (self.receiveDataCount == 2) {
            if (self.readTimer) {
                dispatch_cancel(self.readTimer);
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[MKHudManager share] hide];
        }
        return;
    }
    if ([deviceDic[@"function"] isEqualToString:mk_bleFilteringDeviceNameKey]) {
        //过滤的设备名称
        self.filterTextField.text = dataDic[@"filterName"];
        self.receiveDataCount ++;
        if (self.receiveDataCount == 2) {
            if (self.readTimer) {
                dispatch_cancel(self.readTimer);
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[MKHudManager share] hide];
        }
        return;
    }
}

#pragma mark - event method
- (void)sliderValueChanged {
    NSString *valueString = [NSString stringWithFormat:@"%.f",self.rssiSlider.value];
    self.rssiValueLabel.text = [valueString stringByAppendingString:@"dBm"];
}

- (void)confirmButtonPressed {
    [self configScanFilterRssi];
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
        [self initReadTimer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configScanFilterRssi {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface configDeviceScanFilteringRssi:[self.rssiValueLabel.text integerValue]
                                                   topic:[self.deviceModel currentSubscribedTopic]
                                                  mqttID:self.deviceModel.mqttID
                                                sucBlock:^{
        [self configScanFilterName];
    }
                                             failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configScanFilterName {
    [MKMQTTServerInterface configDeviceScanFilteringName:self.filterTextField.text topic:[self.deviceModel currentSubscribedTopic] mqttID:self.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark -
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBleFilteringRssiNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTServerData:)
                                                 name:MKMQTTServerReceivedBleFilteringDeviceNameNotification
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

#pragma mark - UI
- (void)loadSubViews {
    self.titleLabel.text = self.deviceModel.device_name;
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    [self.view addSubview:self.rssiLabel];
    [self.view addSubview:self.rssiSlider];
    [self.view addSubview:self.rssiValueLabel];
    [self.view addSubview:self.filterNameLabel];
    [self.view addSubview:self.filterTextField];
    [self.view addSubview:self.confirmButton];
    
    [self.rssiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(50.f);
        make.top.mas_equalTo(23.f + defaultTopInset);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rssiSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rssiLabel.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.rssiValueLabel.mas_left).mas_offset(-15.f);
        make.centerY.mas_equalTo(self.rssiLabel.mas_centerY);
        make.height.mas_equalTo(20.f);
    }];
    [self.rssiValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.rssiLabel.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.filterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.top.mas_equalTo(self.rssiSlider.mas_bottom).mas_offset(30.f);
        make.width.mas_equalTo(100.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.filterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.filterNameLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.filterNameLabel.mas_centerY);
        make.height.mas_equalTo(35.f);
    }];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.bottom.mas_equalTo(-50.f);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - setter & getter

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [[UILabel alloc] init];
        _rssiLabel.textColor = DEFAULT_TEXT_COLOR;
        _rssiLabel.textAlignment = NSTextAlignmentLeft;
        _rssiLabel.font = MKFont(15.f);
        _rssiLabel.text = @"RSSI:";
    }
    return _rssiLabel;
}

- (MKSlider *)rssiSlider {
    if (!_rssiSlider) {
        _rssiSlider = [[MKSlider alloc] init];
        _rssiSlider.minimumValue = -100.f;
        _rssiSlider.maximumValue = 0.f;
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

- (UILabel *)filterNameLabel {
    if (!_filterNameLabel) {
        _filterNameLabel = [[UILabel alloc] init];
        _filterNameLabel.textAlignment = NSTextAlignmentLeft;
        _filterNameLabel.textColor = DEFAULT_TEXT_COLOR;
        _filterNameLabel.font = MKFont(15.f);
        _filterNameLabel.text = @"Filter name:";
    }
    return _filterNameLabel;
}

- (UITextField *)filterTextField {
    if (!_filterTextField) {
        _filterTextField = [[UITextField alloc] initWithTextFieldType:normalInput];
        _filterTextField.backgroundColor = COLOR_WHITE_MACROS;
        _filterTextField.borderStyle = UITextBorderStyleNone;
        _filterTextField.textColor = DEFAULT_TEXT_COLOR;
        _filterTextField.font = MKFont(15.f);
        _filterTextField.attributedPlaceholder = [MKAttributedString getAttributedString:@[@"Edit filter name"] fonts:@[MKFont(15.f)] colors:@[RGBCOLOR(222, 222, 222)]];
        _filterTextField.layer.masksToBounds = YES;
        _filterTextField.layer.cornerRadius = 6.f;
    }
    return _filterTextField;
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

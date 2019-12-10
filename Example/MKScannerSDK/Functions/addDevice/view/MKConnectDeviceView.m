//
//  MKConnectDeviceView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConnectDeviceView.h"
#import "MKConnectAlertView.h"

static CGFloat const offset_X = 15.f;
static CGFloat const alertViewHeight = 340.f;
static CGFloat const wifiIconWidth = 179.f;
static CGFloat const wifiIconHeight = 122.f;

static NSString *const titleMsg = @"Connect to device's hotspot";
static NSString *const step1Msg = @"1.Go to your device Settings > Wi-Fi";
static NSString *const step2Msg = @"2.Connect to the Wi-Fi as below";
static NSString *const step3Msg = @"3.Back to the App and continue";

@interface MKConnectDeviceView()

@property (nonatomic, strong)MKConnectAlertView *alertView;

@property (nonatomic, strong)UILabel *step1Label;

@property (nonatomic, strong)UILabel *step2Label;

@property (nonatomic, strong)UIImageView *wifiIcon;

@property (nonatomic, strong)UILabel *step3Label;

@end

@implementation MKConnectDeviceView
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConnectDeviceView销毁");
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        [self setBackgroundColor:RGBCOLOR(102, 102, 102)];
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.step1Label];
        [self.alertView addSubview:self.step2Label];
        [self.alertView addSubview:self.wifiIcon];
        [self.alertView addSubview:self.step3Label];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_right).mas_offset(37.f);
        make.width.mas_equalTo(self.frame.size.width - 2 * 37.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(alertViewHeight);
    }];
    CGFloat width = self.frame.size.width - 2 * 37.f;
    //注意这个，alertView上面的title会自动换行，所以需要动态计算postion_Y
    CGSize titleSize = [NSString sizeWithText:titleMsg
                                      andFont:MKFont(18.f)
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    CGSize step1Size = [NSString sizeWithText:self.step1Label.text
                                      andFont:self.step1Label.font
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    [self.step1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(20.f + titleSize.height + 14.f);
        make.height.mas_equalTo(step1Size.height);
    }];
    CGSize step2Size = [NSString sizeWithText:self.step2Label.text
                                      andFont:self.step2Label.font
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    [self.step2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.step1Label.mas_bottom).mas_offset(14.f);
        make.height.mas_equalTo(step2Size.height);
    }];
    [self.wifiIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
        make.width.mas_equalTo(wifiIconWidth);
        make.top.mas_equalTo(self.step2Label.mas_bottom).mas_offset(17.f);
        make.height.mas_equalTo(wifiIconHeight);
    }];
    CGSize step3Size = [NSString sizeWithText:self.step3Label.text
                                      andFont:self.step3Label.font
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    [self.step3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.wifiIcon.mas_bottom).mas_offset(17.f);
        make.height.mas_equalTo(step3Size.height);
    }];
}

#pragma mark - MKConnectViewProtocol method
- (void)showConnectAlertView{
    [self dismiss];
    self.wifiIcon.image = LOADIMAGE(@"connectAlertWifiSettingsIcon_plug", @"png");
    [kAppWindow addSubview:self];
    [UIView animateWithDuration:.3f animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(-kScreenWidth, 0);
    }];
}

- (void)dismiss{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (BOOL)isShow{
    return (self.superview != nil);
}

#pragma mark - event method
/**
 取消选择
 */
- (void)cancelButtonPressed{
    if ([self.delegate respondsToSelector:@selector(cancelButtonActionWithView:)]) {
        [self.delegate cancelButtonActionWithView:self];
    }
    [self dismiss];
}

/**
 确认选择
 */
- (void)confirmButtonPressed{
    if ([self.delegate respondsToSelector:@selector(confirmButtonActionWithView:returnData:)]) {
        [self.delegate confirmButtonActionWithView:self returnData:nil];
    }
}

#pragma mark - setter & getter
- (MKConnectAlertView *)alertView{
    if (!_alertView) {
        WS(weakSelf);
        _alertView = [[MKConnectAlertView alloc] initWithTitleMsg:titleMsg
                                                     cancelAction:^{
            [weakSelf cancelButtonPressed];
        }
                                                    confirmAction:^{
            [weakSelf confirmButtonPressed];
        }];
    }
    return _alertView;
}

- (UILabel *)step1Label{
    if (!_step1Label) {
        _step1Label = [MKAddDeviceCenter connectAlertMsgLabel:step1Msg];
    }
    return _step1Label;
}

- (UILabel *)step2Label{
    if (!_step2Label) {
        _step2Label = [MKAddDeviceCenter connectAlertMsgLabel:step2Msg];
    }
    return _step2Label;
}

- (UIImageView *)wifiIcon{
    if (!_wifiIcon) {
        _wifiIcon = [[UIImageView alloc] init];
    }
    return _wifiIcon;
}

- (UILabel *)step3Label{
    if (!_step3Label) {
        _step3Label = [MKAddDeviceCenter connectAlertMsgLabel:step3Msg];
    }
    return _step3Label;
}

@end

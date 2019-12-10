//
//  MKConnectDeviceWifiView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConnectDeviceWifiView.h"
#import "MKConnectAlertView.h"

static NSString *const titleMsg = @"Please enter Wi-Fi information";

static CGFloat const offset_X = 15.f;
static CGFloat const wifiLabelWidth = 80.f;
static CGFloat const alertViewHeight = 230.f;

@interface MKConnectDeviceWifiView()

@property (nonatomic, strong)MKConnectAlertView *alertView;

@property (nonatomic, strong)UILabel *wifiNameLabel;

@property (nonatomic, strong)UITextField *wifiNameTextField;

@property (nonatomic, strong)UILabel *wifiPasswordLabel;

@property (nonatomic, strong)UITextField *wifiPasswordTextField;

@end

@implementation MKConnectDeviceWifiView
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConnectDeviceWifiView销毁");
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        [self setBackgroundColor:RGBCOLOR(102, 102, 102)];
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.wifiNameLabel];
        [self.alertView addSubview:self.wifiPasswordLabel];
        [self.alertView addSubview:self.wifiNameTextField];
        [self.alertView addSubview:self.wifiPasswordTextField];
        [self addTapAction:self selector:@selector(hiddenKeyboard)];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_right).mas_offset(37.f);
        make.width.mas_equalTo(self.frame.size.width - 2 * 37.f);
        make.top.mas_equalTo(150.f);
        make.height.mas_equalTo(alertViewHeight);
    }];
    CGFloat width = self.frame.size.width - 2 * 37.f;
    //注意这个，alertView上面的title会自动换行，所以需要动态计算postion_Y
    CGSize titleSize = [NSString sizeWithText:titleMsg
                                      andFont:MKFont(18.f)
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    [self.wifiNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(wifiLabelWidth);
        make.centerY.mas_equalTo(self.wifiNameTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.wifiNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.wifiNameLabel.mas_right).mas_offset(8.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(20.f + titleSize.height + 25.f);
        make.height.mas_equalTo(45.f);
    }];
    [self.wifiPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(wifiLabelWidth);
        make.centerY.mas_equalTo(self.wifiPasswordTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.wifiPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.wifiPasswordLabel.mas_right).mas_offset(8.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.wifiNameTextField.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - MKConnectViewProtocol method
- (void)showConnectAlertView{
    [self dismiss];
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
- (void)hiddenKeyboard{
    [self.wifiPasswordTextField resignFirstResponder];
    [self.wifiNameTextField resignFirstResponder];
}

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
    //先进行校验，看看wifi的ssid和wifi 密码是否输入了
    NSString *ssid = [self.wifiNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *password = [self.wifiPasswordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!ValidStr(ssid)) {
        [self.alertView showCentralToast:@"Please enter a valid name of wifi"];
        return;
    }
    [self hiddenKeyboard];
    if ([self.delegate respondsToSelector:@selector(confirmButtonActionWithView:returnData:)]) {
        [self.delegate confirmButtonActionWithView:self returnData:@{@"ssid":ssid,@"password":password}];
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

- (UILabel *)wifiNameLabel{
    if (!_wifiNameLabel) {
        _wifiNameLabel = [MKAddDeviceCenter connectAlertMsgLabel:@"Wi-Fi:"];
    }
    return _wifiNameLabel;
}

- (UITextField *)wifiNameTextField{
    if (!_wifiNameTextField) {
        _wifiNameTextField = [MKCommonlyUIHelper configServerTextField];
    }
    return _wifiNameTextField;
}

- (UILabel *)wifiPasswordLabel{
    if (!_wifiPasswordLabel) {
        _wifiPasswordLabel = [MKAddDeviceCenter connectAlertMsgLabel:@"Password:"];
    }
    return _wifiPasswordLabel;
}

- (UITextField *)wifiPasswordTextField{
    if (!_wifiPasswordTextField) {
        _wifiPasswordTextField = [MKCommonlyUIHelper configServerTextField];
    }
    return _wifiPasswordTextField;
}

@end

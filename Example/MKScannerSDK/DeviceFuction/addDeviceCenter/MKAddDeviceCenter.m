//
//  MKAddDeviceCenter.m
//  MKBLEGateway
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceCenter.h"

static dispatch_once_t onceToken;
static MKAddDeviceCenter *center = nil;

@implementation MKAddDeviceCenter

- (void)dealloc{
    NSLog(@"MKAddDeviceCenter销毁");
}

+ (MKAddDeviceCenter *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!center) {
            center = [MKAddDeviceCenter new];
        }
    });
    return center;
}

+ (void)deallocCenter{
    onceToken = 0;
    center = nil;
}

+ (UILabel *)connectAlertTitleLabel:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DEFAULT_TEXT_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = MKFont(18.f);
    titleLabel.numberOfLines = 0;
    titleLabel.text = title;
    return titleLabel;
}

+ (UILabel *)connectAlertMsgLabel:(NSString *)text{
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    msgLabel.numberOfLines = 0;
    msgLabel.text = text;
    return msgLabel;
}

/**
 跳转到设置->wifi页面
 */
+ (void)gotoSystemWifiPage{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
        return;
    }
    //低于10
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (NSDictionary *)fecthAddDeviceParams{
    NSString *message = @"Plug in the device and confirm that indicator is blinking amber";
    NSString *gifName = @"addDevice_centerPlugGif";
    NSString *linkMessage = @"My light is not blinking amber";
    NSString *blinkButtonTitle = @"Indicator blink amber light";
    CGFloat gifWidth = 144.f;
    CGFloat gifHeight = 253.f;
    return @{
             addDevice_messageKey:message,
             addDevice_gifNameKey:gifName,
             addDevice_gifWidthKey:@(gifWidth),
             addDevice_gifHeightKey:@(gifHeight),
             addDevice_linkMessageKey:linkMessage,
             addDevice_blinkButtonTitleKey:blinkButtonTitle,
             };
}

- (NSDictionary *)fecthNotBlinkParams{
    NSArray *sourceList = [self fecthNotBlinkAmberDataSource];
    NSString *buttonTitle = @"Indicator blink amber light";
    return @{
             @"sourceList":sourceList,
             @"blinkButtonTitle":buttonTitle,
             };
}

- (NSArray *)fecthNotBlinkAmberDataSource{
    NSDictionary *step1Dic = @{
                               @"stepMsg":@"Step 1",
                               @"operationMsg":@"Plug the device in power",
                               @"leftIconName":@"notBlinkAmberStep1_leftIcon",
                               @"rightIconName":@"notBlinkAmberStep1_rightIcon",
                               };
    NSDictionary *step2Dic = @{
                               @"stepMsg":@"Step 2",
                               @"operationMsg":@"Hold the button for 10s until the LED blink amber",
                               @"leftIconName":@"notBlinkAmberStep2_leftIcon",
                               @"rightIconName":@"notBlinkAmberStep2_rightIcon",
                               };
    return @[step1Dic,step2Dic];
}

@end

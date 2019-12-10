//
//  MKCommonMethod.m
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKCommonMethod.h"

#import "MKDeviceDataBaseManager.h"
#import "MKDeviceServerConfigDatabase.h"

@implementation MKCommonMethod

+ (void)deleteDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target reset:(BOOL)reset{
    if (!deviceModel) {
        return;
    }
    NSString *title = (reset ? @"After reset,the device will be removed from the device list,and relevant data will be totally cleared." : @"Please confirm again whether to remove the device.");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:title
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (reset) {
            //恢复出厂设置
            [self resetDeviceWithModel:deviceModel target:target];
            return;
        }
        //移除设备
        [self deleteDeviceModel:deviceModel target:target];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -
+ (void)resetDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target{
    if (!deviceModel || !ValidStr(deviceModel.mqttID)) {
        return;
    }
    if (deviceModel.plugState == MKBLEGatewayOffline) {
        [target.view showCentralToast:@"Device offline,please check."];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected) {
        [target.view showCentralToast:@"Network error,please check."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Reseting..." inView:target.view isPenetration:NO];
    __weak __typeof(&*target)weakTarget = target;
    WS(weakSelf);
    [MKMQTTServerInterface resetDeviceWithTopic:[deviceModel currentSubscribedTopic] mqttID:deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf deleteDeviceModel:deviceModel target:weakTarget];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

+ (void)deleteDeviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target{
    [[MKHudManager share] showHUDWithTitle:@"Deleting..." inView:target.view isPenetration:NO];
    __weak __typeof(&*target)weakTarget = target;
    [MKDeviceDataBaseManager deleteDeviceWithMQTTID:deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [MKDeviceServerConfigDatabase deleteDeviceServerConfigWithMQTTID:deviceModel.mqttID];
        [[MKMQTTServerManager sharedInstance] unsubscriptions:@[deviceModel.publishedTopic]];
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
        [weakTarget.navigationController popToRootViewControllerAnimated:YES];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

@end

//
//  MKNetworkManager.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNetworkManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NSString *const MKNetworkStatusChangedNotification = @"MKNetworkStatusChangedNotification";

@interface MKNetworkManager()

@property(nonatomic, assign)AFNetworkReachabilityStatus currentNetStatus;//当前网络状态

@end

@implementation MKNetworkManager

+ (MKNetworkManager *)sharedInstance{
    static MKNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKNetworkManager new];
            [manager startMonitoring];
        }
    });
    return manager;
}

#pragma mark - public method

/**
 获取当前手机连接的wifi ssid
 
 @return wifi ssid
 */
+ (NSString *)currentWifiSSID{
    CFArrayRef tempArray = CNCopySupportedInterfaces();
    if (!tempArray) {
        return @"<<NONE>>";
    }
    CFStringRef interfaceName = CFArrayGetValueAtIndex(tempArray, 0);
    CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(interfaceName);
    NSDictionary* wifiDic = (__bridge NSDictionary *) captiveNtwrkDict;
    NSLog(@"%@",wifiDic);
    if (!wifiDic || wifiDic.allValues.count == 0) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    CFRelease(tempArray);
    return wifiDic[@"SSID"];
}

/**
 当前网络是否可用

 @return YES:可用，NO:不可用
 */
- (BOOL)currentNetworkAvailable{
    if (self.currentNetStatus == AFNetworkReachabilityStatusUnknown || self.currentNetStatus == AFNetworkReachabilityStatusNotReachable) {
        return NO;
    }
    return YES;
}

/**
 当前网络是否是wifi

 @return YES:wifi，NO:非wifi
 */
- (BOOL)currentNetworkIsWifi{
    return (self.currentNetStatus == AFNetworkReachabilityStatusReachableViaWiFi);
}

#pragma mark 网络监听相关方法
- (void)startMonitoring{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        self.currentNetStatus = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNetworkStatusChangedNotification object:nil];
    }];
    [mgr startMonitoring];
}

@end

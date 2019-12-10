//
//  MKMQTTServerErrorBlockAdopter.m
//  MKBLEGateway
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerErrorBlockAdopter.h"

NSString * const mqttServerCustomDomain = @"com.moko.MKMQTTServerSDK";

@implementation MKMQTTServerErrorBlockAdopter

+ (NSError *)getErrorWithCode:(serverCustomErrorCode)code message:(NSString *)message{
    NSError *error = [[NSError alloc] initWithDomain:mqttServerCustomDomain
                                                code:code
                                            userInfo:@{@"errorInfo":(message == nil ? @"" : message)}];
    return error;
}

+ (void)operationDisConnectedErrorBlock:(void (^)(NSError *error))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:serverDisconnected message:@"please connect server"]);
        }
    });
}

+ (void)operationTopicErrorBlock:(void (^)(NSError *error))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:serverTopicError message:@"the theme of the error to publish information"]);
        }
    });
}

+ (void)operationSetDataErrorBlock:(void (^)(NSError *error))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:serverSetParamsError message:@"set data error"]);
        }
    });
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:serverParamsError message:@"params error"]);
        }
    });
}

+ (void)operationOTAErrorBlock:(void (^)(NSError *error))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:serverOTAError message:@"OTA error"]);
        }
    });
}

@end

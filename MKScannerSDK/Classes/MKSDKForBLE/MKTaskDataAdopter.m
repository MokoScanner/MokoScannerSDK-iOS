//
//  MKTaskDataAdopter.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKTaskDataAdopter.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "MKBLESDKDefines.h"
#import "MKBLESDKAdopter.h"
#import "MKBLETaskOperationID.h"

@implementation MKTaskDataAdopter

+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic {
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
        return nil;
    }
    return [self parserFF01Data:characteristic];
}

#pragma mark -
+ (NSDictionary *)parserFF01Data:(CBCharacteristic *)characteristic {
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
        return nil;
    }
    NSData *readData = characteristic.value;
    NSString *content = [MKBLESDKAdopter hexStringFromData:readData];
    if (!mk_validData(readData) || !mk_validStr(content) || content.length < 4) {
        return nil;
    }
    NSInteger len = [MKBLESDKAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)];
    if (len * 2 + 4 != content.length) {
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"]) {
        //服务器host
        operationID = mk_configServerHostOperation;
    }else if ([function isEqualToString:@"02"]) {
        //服务器port
        operationID = mk_configServerPortOperation;
    }else if ([function isEqualToString:@"03"]) {
        //服务器clean session
        operationID = mk_configServerCleanSessionOperation;
    }else if ([function isEqualToString:@"04"]) {
        //deviceID
        operationID = mk_configDeviceIDOperation;
    }else if ([function isEqualToString:@"05"]) {
        //clientID
        operationID = mk_configClientIDOperation;
    }else if ([function isEqualToString:@"06"]) {
        //userName
        operationID = mk_configUserNameOperation;
    }else if ([function isEqualToString:@"07"]) {
        //password
        operationID = mk_configPasswordOperation;
    }else if ([function isEqualToString:@"08"]) {
        //keepAlive
        operationID = mk_configServerKeepAliveOperation;
    }else if ([function isEqualToString:@"09"]) {
        //qos
        operationID = mk_configServerQosOperation;
    }else if ([function isEqualToString:@"0a"]) {
        //connect mode
        operationID = mk_configServerConnectModeOperation;
    }else if ([function isEqualToString:@"0b"]) {
        //CA File
        operationID = mk_configCAFileOperation;
    }else if ([function isEqualToString:@"0c"]) {
        //client证书
        operationID = mk_configClientCertOperation;
    }else if ([function isEqualToString:@"0d"]) {
        //client private key
        operationID = mk_configClientPrivateKeyOperation;
    }else if ([function isEqualToString:@"0e"]) {
        //设备发布主题
        operationID = mk_configPublishTopicOperation;
    }else if ([function isEqualToString:@"0f"]) {
        //设备订阅主题
        operationID = mk_configSubscibeTopicOperation;
    }else if ([function isEqualToString:@"10"]) {
        //设备连接服务器
        operationID = mk_configDeviceConnectServerOperation;
    }else if ([function isEqualToString:@"31"]) {
        //联网SSID
        operationID = mk_configWifiSSIDOperation;
    }else if ([function isEqualToString:@"32"]) {
        //联网SSID的密码
        operationID = mk_configWifiPasswordOperation;
    }else if ([function isEqualToString:@"81"]) {
        //服务器host长度
        operationID = mk_configServerHostNumberOperation;
    }else if ([function isEqualToString:@"82"]) {
        //deviceID 长度
        operationID = mk_configDeviceIDNumberOperation;
    }else if ([function isEqualToString:@"83"]) {
        //clientID 长度
        operationID = mk_configClientIDNumberOperation;
    }else if ([function isEqualToString:@"84"]) {
        //userName 长度
        operationID = mk_configUserNameNumberOperation;
    }else if ([function isEqualToString:@"85"]) {
        //password 长度
        operationID = mk_configPasswordNumberOperation;
    }else if ([function isEqualToString:@"86"]) {
        //CA File 长度
        operationID = mk_configCAFileNumberOperation;
    }else if ([function isEqualToString:@"87"]) {
        //client证书 长度
        operationID = mk_configClientCertNumberOperation;
    }else if ([function isEqualToString:@"88"]) {
        //client private key 长度
        operationID = mk_configClientPrivateKeyNumberOperation;
    }else if ([function isEqualToString:@"89"]) {
        //发布主题长度
        operationID = mk_configPublishTopicNumberOperation;
    }else if ([function isEqualToString:@"8a"]) {
        //订阅主题长度
        operationID = mk_configSubscibeTopicNumberOperation;
    }else if ([function isEqualToString:@"8b"]) {
        //wifiSSID长度
        operationID = mk_configWifiSSIDNumberOperation;
    }else if ([function isEqualToString:@"8c"]) {
        //wifi password长度
        operationID = mk_configWifiPasswordNumberOperation;
    }
    NSDictionary *returnData = @{
                                 @"result":@([[content substringWithRange:NSMakeRange(4, 2 * len)] isEqualToString:@"aaaa"])
                                 };
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSNumber *)signedHexTurnString:(NSData *)data{
    if (!data) {
        return nil;
    }
    NSInteger lenth = [data length];
    NSString *maxHexString = [self headString:@"F" trilString:@"F" strLenth:lenth];
    NSString *centerHexString = [self headString:@"8" trilString:@"0" strLenth:lenth];
    NSString *string = [self convertDataToHexString:data];
    if ([[self numberHexString:string] longLongValue] - [[self numberHexString:centerHexString] longLongValue] < 0) {
        return [self numberHexString:string];
    }
    return [NSNumber numberWithLongLong:[[self numberHexString:string] longLongValue] - [[self numberHexString:maxHexString] longLongValue]];
}

// 16进制转10进制
+ (NSNumber *) numberHexString:(NSString *)aHexString {
    if (nil == aHexString) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    return hexNumber;
}

+ (NSString *)headString:(NSString *)headStr trilString:(NSString *)trilStr strLenth:(NSInteger)lenth {
    if (!headStr || !trilStr) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithFormat:@"0x%@", headStr];
    for (int i = 0; i < lenth * 2 - 1; i++)
    {
        [string appendString:trilStr];
    }
    return string;
}

//16进制转NSString
+ (NSString *)convertDataToHexString:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [NSMutableString stringWithString:@"0x"];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *textBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (textBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_taskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end

//
//  MKBLESDKAdopter.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBLESDKAdopter.h"
#import "MKBLESDKDefines.h"

static NSString * const mk_customErrorDomain = @"com.moko.fitpoloBluetoothSDK";

static NSString *const uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";

@implementation MKBLESDKAdopter

#pragma mark - blocks
+ (NSError *)getErrorWithCode:(mk_customErrorCode)code message:(NSString *)message{
    NSError *error = [[NSError alloc] initWithDomain:mk_customErrorDomain
                                                code:code
                                            userInfo:@{@"errorInfo":message}];
    return error;
}

+ (void)operationCentralBlePowerOffBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_bluetoothDisable message:@"mobile phone bluetooth is currently unavailable"];
            block(error);
        }
    });
}

+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_connectedFailed message:@"connect failed"];
            block(error);
        }
    });
}

+ (void)operationDisconnectedErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_peripheralDisconnected message:@"the current connection device is in disconnect"];
            block(error);
        }
    });
}

+ (void)operationCharacteristicErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_characteristicError message:@"characteristic error"];
            block(error);
        }
    });
}

+ (void)operationRequestDataErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_requestPeripheralDataError message:@"request bracelet data error"];
            block(error);
        }
    });
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_paramsError message:@"input parameter error"];
            block(error);
        }
    });
}

+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_setParamsError message:@"set parameter error"];
            block(error);
        }
    });
}

+ (void)operationDeviceTypeErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_deviceTypeUnknowError message:@"device type unknow"];
            block(error);
        }
    });
}

+ (void)operationUnsupportCommandErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_unsupportCommandError message:@"The current device does not support this command"];
            block(error);
        }
    });
}

+ (void)operationGetPackageDataErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_getPackageError message:@"Get package error"];
            block(error);
        }
    });
}

+ (void)operationUpdateErrorBlock:(void (^)(NSError *error))block{
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_updateError message:@"Update failed"];
            block(error);
        }
    });
}

+ (void)operationConnectingErrorBlock:(void (^)(NSError *error))block {
    moko_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:mk_deviceIsConnectingError message:@"The devices are connectting"];
            block(error);
        }
    });
}

+ (void)operationSetParamsResult:(id)returnData
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock{
    if (!mk_validDict(returnData)) {
        [self operationSetParamsErrorBlock:failedBlock];
        return;
    }
    BOOL resultStatus = [returnData[@"result"][@"result"] boolValue];
    if (!resultStatus) {
        [self operationSetParamsErrorBlock:failedBlock];
        return ;
    }
    NSDictionary *resultDic = @{@"msg":@"success",
                                @"code":@"1",
                                @"result":@{},
                                };
    moko_main_safe(^{
        if (sucBlock) {
            sucBlock(resultDic);
        }
    });
}

#pragma mark - parser
+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range{
    if (!mk_validStr(content)) {
        return 0;
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return 0;
    }
    return strtoul([[content substringWithRange:range] UTF8String],0,16);
}
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range{
    if (!mk_validStr(content)) {
        return @"";
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return @"";
    }
    NSInteger decimalValue = strtoul([[content substringWithRange:range] UTF8String],0,16);
    return [NSString stringWithFormat:@"%ld",(long)decimalValue];
}

/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组
 
 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray
                        subRange:(NSRange)range{
    if (!mk_validArray(originalArray)) {
        return nil;
    }
    if (range.location > originalArray.count - 1 || range.length > originalArray.count || (range.location + range.length > originalArray.count)) {
        return nil;
    }
    NSMutableArray *desArray = [NSMutableArray array];
    for (NSInteger i = 0; i < range.length; i ++) {
        [desArray addObject:originalArray[range.location + i]];
    }
    return desArray;
}

/**
 对NSData进行CRC16的校验
 
 @param data 目标data
 @return CRC16校验码
 */
+ (NSData *)getCrc16VerifyCode:(NSData *)data{
    if (!mk_validData(data)) {
        return nil;
    }
    NSInteger crcWord = 0xffff;
    Byte *dataArray = (Byte *)[data bytes];
    for (NSInteger i = 0; i < data.length; i ++) {
        Byte byte = dataArray[i];
        crcWord ^= (NSInteger)byte & 0x00ff;
        for (NSInteger j = 0; j < 8; j ++) {
            if ((crcWord & 0x0001) == 1) {
                crcWord = crcWord >> 1;
                crcWord = crcWord ^ 0xA001;
            }else{
                crcWord = (crcWord >> 1);
            }
        }
    }
    
    Byte crcL = (Byte)0xff & (crcWord >> 8);
    Byte crcH = (Byte)0xff & (crcWord);
    Byte arrayCrc[] = {crcH, crcL};
    NSData *dataCrc = [NSData dataWithBytes:arrayCrc length:sizeof(arrayCrc)];
    return dataCrc;
}

+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)hexStringFromData:(NSData *)sourceData{
    if (!mk_validData(sourceData)) {
        return nil;
    }
    Byte *bytes = (Byte *)[sourceData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[sourceData length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)getTimeStringWithDate:(NSDate *)date{
    if (!date) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSString *timeStamp = [formatter stringFromDate:date];
    if (!mk_validStr(timeStamp)) {
        return nil;
    }
    NSArray *timeList = [timeStamp componentsSeparatedByString:@"-"];
    if (!mk_validArray(timeList) || timeList.count != 5) {
        return nil;
    }
    if ([timeList[0] integerValue] < 2000 || [timeList[0] integerValue] > 2099) {
        return nil;
    }
    unsigned long yearValue = [timeList[0] integerValue] - 2000;
    NSString *hexTimeString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (hexTimeString.length == 1) {
        hexTimeString = [@"0" stringByAppendingString:hexTimeString];
    }
    for (NSInteger i = 1; i < timeList.count; i ++) {
        unsigned long tempValue = [timeList[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        hexTimeString = [hexTimeString stringByAppendingString:hexTempStr];
    }
    return hexTimeString;
}

+ (BOOL)isMacAddress:(NSString *)macAddress{
    if (!mk_validStr(macAddress)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:macAddress];
}
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour{
    if (!mk_validStr(lowFour)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){1}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:lowFour];
}
+ (BOOL)isUUIDString:(NSString *)uuid{
    if (!mk_validStr(uuid)) {
        return NO;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                       options:kNilOptions
                                                         range:NSMakeRange(0, uuid.length)];
    return (numberOfMatches > 0);
}

+ (BOOL)checkIdenty:(NSString *)identy{
    if ([self isMacAddressLowFour:identy]) {
        return YES;
    }
    if ([self isUUIDString:identy]) {
        return YES;
    }
    if ([self isMacAddress:identy]) {
        return YES;
    }
    return NO;
}

+ (NSData *)stringToData:(NSString *)dataString{
    if (!mk_validStr(dataString)) {
        return nil;
    }
    if (!(dataString.length % 2 == 0)) {
        //必须是偶数个字符才是合法的
        return nil;
    }
    Byte bytes[255] = {0};
    NSInteger count = 0;
    for (int i =0; i < dataString.length; i+=2) {
        NSString *strByte = [dataString substringWithRange:NSMakeRange(i,2)];
        unsigned long red = strtoul([strByte UTF8String],0,16);
        Byte b =  (Byte) ((0xff & red) );//( Byte) 0xff&iByte;
        bytes[i/2+0] = b;
        count ++;
    }
    NSData * data = [NSData dataWithBytes:bytes length:count];
    return data;
}

+ (BOOL)checkHexCharacter:(NSString *)character {
    if (!mk_validStr(character)) {
        return NO;
    }
    NSString *regex = @"[a-fA-F0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:character];
}

@end

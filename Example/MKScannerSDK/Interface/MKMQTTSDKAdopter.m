//
//  MKMQTTSDKAdopter.m
//  MKBLEGateway
//
//  Created by aa on 2019/10/12.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKMQTTSDKAdopter.h"

@implementation MKMQTTSDKAdopter

+ (NSInteger)decimalWithHex:(NSString *)content range:(NSRange)range {
    if (!ValidStr(content)) {
        return 0;
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return 0;
    }
    return strtoul([[content substringWithRange:range] UTF8String],0,16);
}
+ (NSString *)decimalStringWithHex:(NSString *)content range:(NSRange)range {
    if (!ValidStr(content)) {
        return @"";
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return @"";
    }
    NSInteger decimalValue = strtoul([[content substringWithRange:range] UTF8String],0,16);
    return [NSString stringWithFormat:@"%ld",(long)decimalValue];
}
+ (NSString *)hexStringFromData:(NSData *)sourceData {
    if (!ValidData(sourceData)) {
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
+ (NSData *)stringToData:(NSString *)dataString {
    if (!ValidStr(dataString)) {
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

+ (NSNumber *)fetchRSSIWithContent:(NSData *)contentData{
    const unsigned char *cData = [contentData bytes];
    unsigned char *data;
    // Malloc advertise data for char*
    data = malloc(sizeof(unsigned char) * contentData.length);
    NSAssert(data, @"failed to malloc");
    for (int i = 0; i < contentData.length; i++) {
        data[i] = *cData++;
    }
    unsigned char txPowerChar = *data;
    if (txPowerChar & 0x80) {
        return [NSNumber numberWithInt:(- 0x100 + txPowerChar)];
    }
    else {
        return [NSNumber numberWithInt:txPowerChar];
    }
}

+ (NSString *)fetchDeviceIDMode:(NSString *)mqttID {
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)mqttID.length];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < mqttID.length; i ++) {
        int asciiCode = [mqttID characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    return [lenString stringByAppendingString:tempString];
}

+ (NSString *)hexStringFromSignedNumber:(NSInteger)number {
    NSString *tempNumber = [NSString stringWithFormat:@"%lX", (long)number];
    if (tempNumber.length == 1) {
        tempNumber = [@"0" stringByAppendingString:tempNumber];
    }
    NSData *data = [self stringToData:tempNumber];
    NSData *resultData = [data subdataWithRange:NSMakeRange(data.length - 1, 1)];
    return [self hexStringFromData:resultData];
}

@end

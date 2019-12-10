//
//  MKMQTTSDKAdopter.h
//  MKBLEGateway
//
//  Created by aa on 2019/10/12.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMQTTSDKAdopter : NSObject

+ (NSInteger)decimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)decimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSData *)stringToData:(NSString *)dataString;
+ (NSNumber *)fetchRSSIWithContent:(NSData *)contentData;
+ (NSString *)fetchDeviceIDMode:(NSString *)mqttID;
+ (NSString *)hexStringFromSignedNumber:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END

//
//  MKBLESDKAdopter.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, mk_customErrorCode){
    mk_bluetoothDisable = -10000,                                //当前手机蓝牙不可用
    mk_connectedFailed = -10001,                                 //连接外设失败
    mk_peripheralDisconnected = -10002,                          //当前外部连接的设备处于断开状态
    mk_characteristicError = -10003,                             //特征为空
    mk_requestPeripheralDataError = -10004,                      //请求手环数据出错
    mk_paramsError = -10005,                                     //输入的参数有误
    mk_setParamsError = -10006,                                  //设置参数出错
    mk_getPackageError = -10007,                                 //升级固件的时候，传过来的固件数据出错
    mk_updateError = -10008,                                     //升级失败
    mk_deviceTypeUnknowError = -10009,                           //设备类型错误
    mk_unsupportCommandError = -10010,                           //设备不支持该条命令
    mk_deviceIsConnectingError = -10011,                         //设备正在连接,不允许重复连接
};

@interface MKBLESDKAdopter : NSObject

#pragma mark - blocks
+ (NSError *)getErrorWithCode:(mk_customErrorCode)code message:(NSString *)message;
+ (void)operationCentralBlePowerOffBlock:(void (^)(NSError *error))block;
+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block;
+ (void)operationDisconnectedErrorBlock:(void (^)(NSError *error))block;
+ (void)operationCharacteristicErrorBlock:(void (^)(NSError *error))block;
+ (void)operationRequestDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationDeviceTypeErrorBlock:(void (^)(NSError *error))block;
+ (void)operationUnsupportCommandErrorBlock:(void (^)(NSError *error))block;
+ (void)operationGetPackageDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationUpdateErrorBlock:(void (^)(NSError *error))block;
+ (void)operationConnectingErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsResult:(id)returnData
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

#pragma mark - parser
+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSData *)getCrc16VerifyCode:(NSData *)data;

/// 普通字符串转换成16进制字符串
/// @param string 字符串
+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
+ (NSData *)stringToData:(NSString *)dataString;
+ (BOOL)isMacAddress:(NSString *)macAddress;
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour;
+ (BOOL)isUUIDString:(NSString *)uuid;
+ (BOOL)checkIdenty:(NSString *)identy;
+ (BOOL)checkHexCharacter:(NSString *)character;

@end

NS_ASSUME_NONNULL_END

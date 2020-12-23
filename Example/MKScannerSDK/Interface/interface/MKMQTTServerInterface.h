//
//  MKMQTTServerInterface.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMQTTServerInterface : NSObject

/**
 Factory Reset
 
 @param topic topic
 @param mqttID mqttID
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)resetDeviceWithTopic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备是否开启了蓝牙扫描
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceScanStatusWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备扫描间隔
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceScanIntervalWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备蓝牙过滤RSSI
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceScanFilteringRssiWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备蓝牙过滤名称
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceScanFilteringNameWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/**
 读取公司名字

 @param topic topic
 @param mqttID mqttID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)readCompanyNameWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取生产日期
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDateOfManufactureWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取产品型号
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readProductModeWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取固件版本
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readFirmwareVersionWithTopic:(NSString *)topic
                              mqttID:(NSString *)mqttID
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取mac地址
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceMacAddressWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备名称
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceNameWithTopic:(NSString *)topic
                         mqttID:(NSString *)mqttID
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备的LED设置
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceLEDSettingWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取过滤蓝牙原始数据规则
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceRawFilterDataWithTopic:(NSString *)topic
                                  mqttID:(NSString *)mqttID
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取过滤蓝牙mac地址
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceMacFilterDataWithTopic:(NSString *)topic
                                  mqttID:(NSString *)mqttID
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取数据超时时长
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readDeviceDataReportSettingTimeWithTopic:(NSString *)topic
                                          mqttID:(NSString *)mqttID
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock;

@end

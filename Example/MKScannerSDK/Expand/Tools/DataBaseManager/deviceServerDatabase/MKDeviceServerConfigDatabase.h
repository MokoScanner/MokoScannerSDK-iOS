//
//  MKDeviceServerConfigDatabase.h
//  MKBLEGateway
//
//  Created by aa on 2019/10/14.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceServerConfigDatabase : NSObject

/**
 添加的设备入库

 @param deviceList 设备列表
 @param sucBlock 入库成功
 @param failedBlock 入库失败
 */
+ (void)insertDeviceList:(NSArray <MKConfigServerModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// 根据mqttID查询本地的设备MQTT服务器配置
/// @param mqttID mqttID
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)selecteDeviceServerConfigWithMQTTID:(NSString *)mqttID
                                   sucBlock:(void (^)(MKConfigServerModel *serverModel))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

/// 根据mqttID删除本地设备的MQTT服务器配置信息
/// @param mqttID mqttID
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)deleteDeviceServerConfigWithMQTTID:(NSString *)mqttID
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// 根据mqttID删除本地设备的MQTT服务器配置信息
/// @param mqttID mqttID
+(BOOL)deleteDeviceServerConfigWithMQTTID:(NSString *)mqttID;

@end

NS_ASSUME_NONNULL_END

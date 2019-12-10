//
//  MKDeviceDataBaseManager.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDeviceDataBaseManager : NSObject

/**
 添加的设备入库

 @param deviceList 设备列表
 @param sucBlock 入库成功
 @param failedBlock 入库失败
 */
+ (void)insertDeviceList:(NSArray <MKDeviceModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/**
 获取本地数据库存储的设备列表
 
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)getLocalDeviceListWithSucBlock:(void (^)(NSArray <MKDeviceModel *>*deviceList))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/**
 更新本地deviceModel，Key为mac地址

 @param deviceModel model
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)updateDevice:(MKDeviceModel *)deviceModel
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;
/**
 删除指定mqttID的设备
 
 @param mqttID mqttID
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)deleteDeviceWithMQTTID:(NSString *)mqttID
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;
/**
 根据mqttID地址查询localName
 
 @param mqttID mqttID
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)selectLocalNameWithMQTTID:(NSString *)mqttID
                         sucBlock:(void (^)(NSString *localName))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

@end

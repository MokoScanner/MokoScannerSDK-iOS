//
//  MKDeviceDataBaseManager.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceDataBaseManager.h"
#import "MKDeviceDataBaseAdopter.h"
#import "FMDB.h"

static char *const MKDeviceDataBaseOperationQueue = "MKDeviceDataBaseOperationQueue";

@implementation MKDeviceDataBaseManager

/**
 添加的设备入库
 
 @param deviceList 设备列表
 @param sucBlock 入库成功
 @param failedBlock 入库失败
 */
+ (void)insertDeviceList:(NSArray <MKDeviceModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock{
    if (!deviceList) {
        [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
        return;
    }
    if (deviceList.count == 0) {
        moko_dispatch_main_safe(^{
            sucBlock();
        });
        return;
    }
    dispatch_queue_t queueInsert = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueInsert, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        BOOL resCreate = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceTable (clientID text NOT NULL,device_name text NOT NULL,mqttID text NOT NULL, subscribedTopic text NOT NULL,publishedTopic text NOT NULL,deviceUUID text NOT NULL);"];
        if (!resCreate) {
            [db close];
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        for (MKDeviceModel *model in deviceList) {
            BOOL exist = NO;
            FMResultSet * result = [db executeQuery:@"select * from deviceTable where mqttID = ?",model.mqttID];
            while (result.next) {
                if ([model.mqttID isEqualToString:[result stringForColumn:@"mqttID"]]) {
                    exist = YES;
                }
            }
            if (exist) {
                //存在该设备，更新设备
                [db executeUpdate:@"UPDATE deviceTable SET device_name = ?, clientID = ?, subscribedTopic = ? ,publishedTopic = ? ,deviceUUID = ? WHERE mqttID = ?",SafeStr(model.device_name),SafeStr(model.clientID),SafeStr(model.subscribedTopic),SafeStr(model.publishedTopic),SafeStr(model.deviceUUID),SafeStr(model.mqttID)];
            }else{
                //不存在，插入设备
                [db executeUpdate:@"INSERT INTO deviceTable (device_name, clientID, subscribedTopic, publishedTopic, mqttID,deviceUUID) VALUES (?,?,?,?,?,?);",SafeStr(model.device_name),SafeStr(model.clientID),SafeStr(model.subscribedTopic),SafeStr(model.publishedTopic),SafeStr(model.mqttID),SafeStr(model.deviceUUID)];
            }
            
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    });
}

/**
 获取本地数据库存储的设备列表

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)getLocalDeviceListWithSucBlock:(void (^)(NSArray <MKDeviceModel *>*deviceList))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock{
    dispatch_queue_t queueInsert = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueInsert, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationGetDataFailedBlock:failedBlock];
            return;
        }
        NSMutableArray *dataList = [NSMutableArray array];
        FMResultSet * result = [db executeQuery:@"SELECT * FROM deviceTable"];
        while ([result next]) {
            MKDeviceModel *deviceModel = [[MKDeviceModel alloc] init];
            deviceModel.device_name = [result stringForColumn:@"device_name"];
            deviceModel.clientID = [result stringForColumn:@"clientID"];
            deviceModel.subscribedTopic = [result stringForColumn:@"subscribedTopic"];
            deviceModel.publishedTopic = [result stringForColumn:@"publishedTopic"];
            deviceModel.mqttID = [result stringForColumn:@"mqttID"];
            deviceModel.deviceUUID = [result stringForColumn:@"deviceUUID"];
            [dataList addObject:deviceModel];
        }
        [db close];
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock(dataList);
            });
        }
    });
}

/**
 更新本地deviceModel，Key为mac地址
 
 @param deviceModel model
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)updateDevice:(MKDeviceModel *)deviceModel
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock{
    if (!deviceModel || !ValidStr(deviceModel.mqttID)) {
        [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
            return;
        }
        BOOL resUpdate = [db executeUpdate:@"UPDATE deviceTable SET device_name = ?, clientID = ?, subscribedTopic = ? ,publishedTopic = ? ,deviceUUID = ? WHERE mqttID = ?",SafeStr(deviceModel.device_name),SafeStr(deviceModel.clientID),SafeStr(deviceModel.subscribedTopic),SafeStr(deviceModel.publishedTopic),SafeStr(deviceModel.deviceUUID),SafeStr(deviceModel.mqttID)];
        [db close];
        if (!resUpdate) {
            [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
            return;
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
    });
}

+ (void)deleteDeviceWithMQTTID:(NSString *)mqttID
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock{
    if (!ValidStr(mqttID)) {
        [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        BOOL result = [db executeUpdate:@"DELETE FROM deviceTable WHERE mqttID = ?",mqttID];
        if (!result) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
    });
}

+ (void)selectLocalNameWithMQTTID:(NSString *)mqttID
                         sucBlock:(void (^)(NSString *localName))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock{
    if (!ValidStr(mqttID)) {
        [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        FMResultSet * result = [db executeQuery:@"select * from deviceTable where mqttID = ?",mqttID];
        NSString *localName = @"";
        while ([result next]) {
            localName = [result stringForColumn:@"device_name"];
        }
        [db close];
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock(localName);
            });
        }
    });
}

@end

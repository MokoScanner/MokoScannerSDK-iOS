//
//  MKDeviceServerConfigDatabase.m
//  MKBLEGateway
//
//  Created by aa on 2019/10/14.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceServerConfigDatabase.h"
#import "MKDeviceDataBaseAdopter.h"
#import "FMDB.h"

static char *const MKDeviceServerConfigDatabaseOperationQueue = "MKDeviceServerConfigDatabaseOperationQueue";

@implementation MKDeviceServerConfigDatabase

+ (void)insertDeviceList:(NSArray <MKConfigServerModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
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
    dispatch_queue_t queueInsert = dispatch_queue_create(MKDeviceServerConfigDatabaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueInsert, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceMQTTServerDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        BOOL resCreate = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceMQTTServerTable (mqttID text NOT NULL,port text NOT NULL,host text NOT NULL,cleanSession text NOT NULL, connectMode text NOT NULL,qos text NOT NULL,keepAlive text NOT NULL,clientId text NOT NULL,userName text NOT NULL,password text NOT NULL,caFileName text NOT NULL,clientP12CertName text NOT NULL,clientKeyName text NOT NULL,clientCertName text NOT NULL,subscribedTopic text NOT NULL,publishedTopic text NOT NULL);"];
        if (!resCreate) {
            [db close];
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        BOOL success = NO;
        for (MKConfigServerModel *model in deviceList) {
            BOOL exist = NO;
            FMResultSet * result = [db executeQuery:@"select * from deviceMQTTServerTable where mqttID = ?",model.mqttID];
            while (result.next) {
                if ([model.mqttID isEqualToString:[result stringForColumn:@"mqttID"]]) {
                    exist = YES;
                }
            }
            NSString *cleanSession = (model.cleanSession ? @"01" : @"00");
            NSString *connectMode = [NSString stringWithFormat:@"%ld",(long)model.connectMode];
            if (exist) {
                //存在该设备，更新设备
                success = [db executeUpdate:@"UPDATE deviceMQTTServerTable SET host = ?, port = ?, cleanSession = ? ,connectMode = ? ,qos = ? ,keepAlive = ?, clientId = ?, userName = ?, password = ?, caFileName = ?,clientP12CertName = ?, clientKeyName = ?, clientCertName = ?, subscribedTopic = ?, publishedTopic = ? WHERE mqttID = ?",SafeStr(model.host),SafeStr(model.port),SafeStr(cleanSession),SafeStr(connectMode),SafeStr(model.qos),SafeStr(model.keepAlive),SafeStr(model.clientId),SafeStr(model.userName),SafeStr(model.password),SafeStr(model.caFileName),SafeStr(model.clientP12CertName),SafeStr(model.clientKeyName),SafeStr(model.clientCertName),SafeStr(model.subscribedTopic),SafeStr(model.publishedTopic),SafeStr(model.mqttID)];
            }else{
                //不存在，插入设备
                success = [db executeUpdate:@"INSERT INTO deviceMQTTServerTable (mqttID, host, port, cleanSession, connectMode,qos,keepAlive,clientId,userName,password,caFileName,clientP12CertName,clientKeyName,clientCertName,subscribedTopic,publishedTopic) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",SafeStr(model.mqttID),SafeStr(model.host),SafeStr(model.port),SafeStr(cleanSession),SafeStr(connectMode),SafeStr(model.qos),SafeStr(model.keepAlive),SafeStr(model.clientId),SafeStr(model.userName),SafeStr(model.password),SafeStr(model.caFileName),SafeStr(model.clientP12CertName),SafeStr(model.clientKeyName),SafeStr(model.clientCertName),SafeStr(model.subscribedTopic),SafeStr(model.publishedTopic)];
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

+ (void)selecteDeviceServerConfigWithMQTTID:(NSString *)mqttID
                                   sucBlock:(void (^)(MKConfigServerModel *serverModel))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(mqttID)) {
        [MKDeviceDataBaseAdopter operationGetDataFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceServerConfigDatabaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceMQTTServerDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationGetDataFailedBlock:failedBlock];
            return;
        }
        FMResultSet * result = [db executeQuery:@"select * from deviceMQTTServerTable where mqttID = ?",mqttID];
        MKConfigServerModel *dataModel = [[MKConfigServerModel alloc] init];
        while ([result next]) {
            dataModel.host = [result stringForColumn:@"host"];
            dataModel.port = [result stringForColumn:@"port"];
            dataModel.cleanSession = [[result stringForColumn:@"cleanSession"] isEqualToString:@"01"];
            dataModel.connectMode = [[result stringForColumn:@"connectMode"] integerValue];
            dataModel.qos = [result stringForColumn:@"qos"];
            dataModel.keepAlive = [result stringForColumn:@"keepAlive"];
            dataModel.clientId = [result stringForColumn:@"clientId"];
            dataModel.userName = [result stringForColumn:@"userName"];
            dataModel.password = [result stringForColumn:@"password"];
            dataModel.caFileName = [result stringForColumn:@"caFileName"];
            dataModel.clientP12CertName = [result stringForColumn:@"clientP12CertName"];
            dataModel.clientKeyName = [result stringForColumn:@"clientKeyName"];
            dataModel.clientCertName = [result stringForColumn:@"clientCertName"];
            dataModel.subscribedTopic = [result stringForColumn:@"subscribedTopic"];
            dataModel.publishedTopic = [result stringForColumn:@"publishedTopic"];
            dataModel.mqttID = [result stringForColumn:@"mqttID"];
        }
        [db close];
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock(dataModel);
            });
        }
    });
}

+ (void)deleteDeviceServerConfigWithMQTTID:(NSString *)mqttID
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(mqttID)) {
        [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceServerConfigDatabaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceMQTTServerDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        BOOL result = [db executeUpdate:@"DELETE FROM deviceMQTTServerTable WHERE mqttID = ?",mqttID];
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

+(BOOL)deleteDeviceServerConfigWithMQTTID:(NSString *)mqttID {
    if (!ValidStr(mqttID)) {
        return NO;
    }
    FMDatabase* db = [FMDatabase databaseWithPath:deviceMQTTServerDBPath];
    if (![db open]) {
        return NO;
    }
    BOOL result = [db executeUpdate:@"DELETE FROM deviceMQTTServerTable WHERE mqttID = ?",mqttID];
    return result;
}

@end

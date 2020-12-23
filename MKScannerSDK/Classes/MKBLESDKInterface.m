//
//  MKBLESDKInterface.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBLESDKInterface.h"
#import "MKScannerCentralManager.h"
#import "MKBLESDKAdopter.h"
#import "MKBLETaskOperationID.h"
#import "CBPeripheral+MKBLEAdd.h"
#import "MKBLETaskOperation.h"

static NSTimeInterval const defaultTimeCoefficient = 0.05;

#define connectedPeripheral (currentCentral.peripheral)
#define currentCentral ([MKScannerCentralManager shared])

@implementation MKBLESDKInterface

#pragma mark - interface
+ (void)configServerHost:(NSString *)host
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!host || host.length == 0 || host.length > 63) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < host.length; i ++) {
        int asciiCode = [host characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("configServerHostQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:host.length key:@"81" taskID:mk_configServerHostNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configServerHostOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"01" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configServerPort:(NSInteger)port
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (port < 0 || port > 65535) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *portNum = [self fetchDataIndex:port];
    NSString *commandString = [@"0202" stringByAppendingString:portNum];
    [currentCentral addTaskWithTaskID:mk_configServerPortOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:commandString
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configServerCleanSession:(BOOL)clean
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock {
    NSString *commandString = (clean ? @"030101" : @"030100");
    [currentCentral addTaskWithTaskID:mk_configServerCleanSessionOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:commandString
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configDeviceID:(NSString *)deviceID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!deviceID || deviceID.length < 1 || deviceID.length > 32) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < deviceID.length; i ++) {
        int asciiCode = [deviceID characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configDeviceIDQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:deviceID.length key:@"82" taskID:mk_configDeviceIDNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configDeviceIDOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"04" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configClientID:(NSString *)clientID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!clientID || clientID.length == 0 || clientID.length > 64) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < clientID.length; i ++) {
        int asciiCode = [clientID characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configClientIDQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:clientID.length key:@"83" taskID:mk_configClientIDNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configClientIDOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"05" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configUserName:(NSString *)userName
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (userName.length > 255) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (!userName || userName.length == 0) {
        NSDictionary *dic = @{
                              @"msg":@"success",
                              @"code":@"1",
                              @"result":@{},
                              };
        moko_main_safe(^{
            sucBlock(dic);
        });
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < userName.length; i ++) {
        int asciiCode = [userName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configUserNameQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:userName.length key:@"84" taskID:mk_configUserNameNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configUserNameOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"06" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configPassword:(NSString *)password
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (password.length > 255) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (!password || password.length == 0) {
        NSDictionary *dic = @{
                              @"msg":@"success",
                              @"code":@"1",
                              @"result":@{},
                              };
        moko_main_safe(^{
            sucBlock(dic);
        });
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < password.length; i ++) {
        int asciiCode = [password characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configPasswordQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:password.length key:@"85" taskID:mk_configPasswordNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configPasswordOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"07" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configKeepAlive:(NSInteger)keepAlive
               sucBlock:(mk_communicationSuccessBlock)sucBlock
            failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (keepAlive < 0 || keepAlive > 120) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *keepString = [NSString stringWithFormat:@"%1lx",(long)keepAlive];
    if (keepString.length == 1) {
        keepString = [@"0" stringByAppendingString:keepString];
    }
    NSString *commandString = [@"0801" stringByAppendingString:keepString];
    [currentCentral addTaskWithTaskID:mk_configServerKeepAliveOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:commandString
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configQos:(mqttServerQosMode)qosMode
         sucBlock:(mk_communicationSuccessBlock)sucBlock
      failedBlock:(mk_communicationFailedBlock)failedBlock {
    NSString *commandString = @"090100";
    if (qosMode == mqttQosLevelAtLeastOnce) {
        commandString = @"090101";
    }else if (qosMode == mqttQosLevelExactlyOnce) {
        commandString = @"090102";
    }
    [currentCentral addTaskWithTaskID:mk_configServerQosOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:commandString
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configConnectMode:(mqttServerConnectMode)connectMode
                 sucBlock:(mk_communicationSuccessBlock)sucBlock
              failedBlock:(mk_communicationFailedBlock)failedBlock {
    NSString *commandString = @"0a0100";
    if (connectMode == mqttServerConnectOneWaySSLMode) {
        //单向
        commandString = @"0a0101";
    }else if (connectMode == mqttServerConnectTwoWaySSLMode) {
        //双向
        commandString = @"0a0102";
    }
    [currentCentral addTaskWithTaskID:mk_configServerConnectModeOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:commandString
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configCAFile:(NSData *)caFile
            sucBlock:(mk_communicationSuccessBlock)sucBlock
         failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validData(caFile)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *caData = [MKBLESDKAdopter hexStringFromData:caFile];
    if (!mk_validStr(caData)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("configCAFileQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:caFile.length key:@"86" taskID:mk_configCAFileNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = caData.length / 16;
        if (caData.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configCAFileOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"0b" commandString:caData];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient + 5;
        [currentCentral addTask:operation];
    });
}

+ (void)configClientCert:(NSData *)cert
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validData(cert)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *certData = [MKBLESDKAdopter hexStringFromData:cert];
    if (!mk_validStr(certData)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("configClientCertQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:cert.length key:@"87" taskID:mk_configClientCertNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = certData.length / 16;
        if (certData.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configClientCertOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"0c" commandString:certData];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient + 5;
        [currentCentral addTask:operation];
    });
}

+ (void)configClientPrivateKey:(NSData *)privateKey
                      sucBlock:(mk_communicationSuccessBlock)sucBlock
                   failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validData(privateKey)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *keyData = [MKBLESDKAdopter hexStringFromData:privateKey];
    if (!mk_validStr(keyData)) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("configClientPrivateKeyQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:privateKey.length key:@"88" taskID:mk_configClientPrivateKeyNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = keyData.length / 16;
        if (keyData.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configClientPrivateKeyOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"0d" commandString:keyData];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient + 5;
        [currentCentral addTask:operation];
    });
}

+ (void)configDevicePublishTopic:(NSString *)publishTopic
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validStr(publishTopic) || publishTopic.length > 128) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < publishTopic.length; i ++) {
        int asciiCode = [publishTopic characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configPublishTopicQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:publishTopic.length key:@"89" taskID:mk_configPublishTopicNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configPublishTopicOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"0e" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configDeviceSubscibeTopic:(NSString *)subscibeTopic
                         sucBlock:(mk_communicationSuccessBlock)sucBlock
                      failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validStr(subscibeTopic) || subscibeTopic.length > 128) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < subscibeTopic.length; i ++) {
        int asciiCode = [subscibeTopic characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configSubscibeTopicQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:subscibeTopic.length key:@"8a" taskID:mk_configSubscibeTopicNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configSubscibeTopicOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"0f" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configWifiSSID:(NSString *)wifiSSID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validStr(wifiSSID) || wifiSSID.length > 100) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = [MKBLESDKAdopter hexStringFromString:wifiSSID];
    dispatch_queue_t queue = dispatch_queue_create("configWifiSSIDQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:(tempString.length / 2) key:@"8b" taskID:mk_configWifiSSIDNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configWifiSSIDOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"31" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configWifiPassword:(NSString *)password
                  sucBlock:(mk_communicationSuccessBlock)sucBlock
               failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (!mk_validStr(password) || password.length > 100) {
        [MKBLESDKAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < password.length; i ++) {
        int asciiCode = [password characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    dispatch_queue_t queue = dispatch_queue_create("configWifiPasswordQueue", 0);
    dispatch_async(queue, ^{
        if (![self configTotalNumber:password.length key:@"8c" taskID:mk_configWifiPasswordNumberOperation]) {
            [MKBLESDKAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        NSInteger totalIndex = tempString.length / 16;
        if (tempString.length % 16) {
            totalIndex += 1;
        }
        MKBLETaskOperation *operation = [[MKBLETaskOperation alloc] initOperationWithID:mk_configWifiPasswordOperation resetNum:NO commandBlock:^{
            [self sendDataToDevice:@"32" commandString:tempString];
        } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
            [self taskCompleteParser:error returnData:returnData sucBlock:sucBlock failedBlock:failedBlock];
        }];
        
        operation.receiveTimeout = totalIndex * defaultTimeCoefficient;
        [currentCentral addTask:operation];
    });
}

+ (void)configDeviceConnectServerWithSucBlock:(mk_communicationSuccessBlock)sucBlock
                                  failedBlock:(mk_communicationFailedBlock)failedBlock {
    [currentCentral addTaskWithTaskID:mk_configDeviceConnectServerOperation
                       characteristic:connectedPeripheral.dataCharacteristic
                             resetNum:NO
                          commandData:@"100101"
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

#pragma mark - private method

+ (NSString *)fetchDataIndex:(NSInteger)index {
    NSString *indexString = [NSString stringWithFormat:@"%1lx",(long)index];
    if (indexString.length == 1) {
        indexString = [@"000" stringByAppendingString:indexString];
    }else if (indexString.length == 2) {
        indexString = [@"00" stringByAppendingString:indexString];
    }else if (indexString.length == 3) {
        indexString = [@"0" stringByAppendingString:indexString];
    }
    return indexString;
}

+ (BOOL)configTotalNumber:(NSInteger)totalNumber key:(NSString *)key taskID:(mk_taskOperationID)taskID {
    NSInteger totalIndex = totalNumber / 16;
    if (totalNumber % 16) {
        totalIndex += 1;
    }
    NSString *totalNumIndexString = [self fetchDataIndex:totalIndex];
    NSString *dataLen = [self fetchDataIndex:totalNumber];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",key,totalNumIndexString,dataLen];
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [currentCentral addTaskWithTaskID:taskID characteristic:connectedPeripheral.dataCharacteristic resetNum:NO commandData:commandString successBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failureBlock:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (void)taskCompleteParser:(NSError *)error
                returnData:(id)returnData
                  sucBlock:(mk_communicationSuccessBlock)sucBlock
               failedBlock:(mk_communicationFailedBlock)failedBlock {
    if (error) {
        moko_main_safe(^{
            if (failedBlock) {
                failedBlock(error);
            }
        });
        return ;
    }
    if (!returnData) {
        [MKBLESDKAdopter operationRequestDataErrorBlock:failedBlock];
        return ;
    }
    NSString *lev = returnData[mk_dataStatusLev];
    if ([lev isEqualToString:@"1"]) {
        //通用无附加信息的
        NSArray *dataList = (NSArray *)returnData[mk_dataInformation];
        if (!dataList) {
            [MKBLESDKAdopter operationRequestDataErrorBlock:failedBlock];
            return;
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                    };
        [MKBLESDKAdopter operationSetParamsResult:resultDic sucBlock:sucBlock failedBlock:failedBlock];
        return;
    }
    //对于有附加信息的
    NSDictionary *resultDic = @{@"msg":@"success",
                                @"code":@"1",
                                @"result":returnData[mk_dataInformation],
                                };
    moko_main_safe(^{
        if (sucBlock) {
            sucBlock(resultDic);
        }
    });
}

+ (NSArray *)commandDataList:(NSString *)commandString key:(NSString *)key {
    if (commandString.length % 2) {
        return @[];
    }
    NSInteger total = commandString.length / 32;
    NSInteger remind = commandString.length % 32;
    if (remind > 0) {
        total += 1;
    }
    //注意，包序号从0001开始
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:total];
    for (NSInteger i = 0; i < total - 1; i ++) {
        NSString *index = [self fetchDataIndex:(i + 1)];
        NSString *command = [NSString stringWithFormat:@"%@%@%@%@",key,index,@"10",[commandString substringWithRange:NSMakeRange(i * 32, 32)]];
        [dataList addObject:command];
    }
    NSString *index = [self fetchDataIndex:total];
    //添加最后一帧数据
    NSInteger need = 32;
    if (remind > 0) {
        need = remind;
    }
    NSString *tempNum = [NSString stringWithFormat:@"%1lx",(long)(need / 2)];
    if (tempNum.length == 1) {
        tempNum = [@"0" stringByAppendingString:tempNum];
    }
    NSString *command = [NSString stringWithFormat:@"%@%@%@%@",key,index,tempNum,[commandString substringWithRange:NSMakeRange((total - 1) * 32, need)]];
    [dataList addObject:command];
    return dataList;
}

+ (void)sendDataToDevice:(NSString *)key commandString:(NSString *)commandString {
    NSArray *dataList = [self commandDataList:commandString key:key];
    if (!mk_validArray(dataList)) {
        return;
    }
    __block NSInteger index = 0;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, defaultTimeCoefficient * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [currentCentral sendCommandToPeripheral:dataList[index] characteristic:connectedPeripheral.dataCharacteristic];
        if (index == dataList.count - 1) {
            //最后一帧
            dispatch_cancel(timer);
            return ;
        }
        index ++;
    });
    dispatch_resume(timer);
}

@end

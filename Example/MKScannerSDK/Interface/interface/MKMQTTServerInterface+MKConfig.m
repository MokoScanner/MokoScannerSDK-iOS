//
//  MKMQTTServerInterface+MKConfig.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKMQTTServerInterface+MKConfig.h"
#import "MKMQTTServerErrorBlockAdopter.h"
#import "MKMQTTSDKAdopter.h"

@implementation MKMQTTServerInterface (MKConfig)

+ (void)configDeviceScanStatus:(BOOL)isOn
                         topic:(NSString *)topic
                        mqttID:(NSString *)mqttID
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *status = (isOn ? @"01" : @"00");
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"26",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0001",status];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configDeviceScanInterval:(NSInteger)interval
                           topic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 10 || interval > 65535) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *intervalString = [self fourLenHex:interval];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"27",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0002",intervalString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configDeviceScanFilteringRssi:(NSInteger)rssi
                                topic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    if (rssi > 0 || rssi < -100) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rssiValue = [MKMQTTSDKAdopter hexStringFromSignedNumber:rssi];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"25",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0001",rssiValue];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configDeviceScanFilteringName:(NSString *)filteringName
                                topic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    if (ValidStr(filteringName) && filteringName.length > 29) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (!filteringName) {
        filteringName = @"";
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < filteringName.length; i ++) {
        int asciiCode = [filteringName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *nameLen = [self fourLenHex:filteringName.length];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"29",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],nameLen,tempString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configLEDSettings:(id <MKLEDSettingProtocol>)protocol
                    topic:(NSString *)topic
                   mqttID:(NSString *)mqttID
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (!protocol || ![protocol conformsToProtocol:@protocol(MKLEDSettingProtocol)]) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *serverConnectingIson = (protocol.serverConnectingIson ? @"01" : @"00");
    NSString *serverConnectedIson = (protocol.serverConnectedIson ? @"01" : @"00");
    NSString *bleBroadcastIson = (protocol.bleBroadcastIson ? @"01" : @"00");
    NSString *bleConnectingIson = (protocol.bleConnectingIson ? @"01" : @"00");
    NSString *tempString = [NSString stringWithFormat:@"%@%@%@%@",serverConnectingIson,serverConnectedIson,bleBroadcastIson,bleConnectingIson];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"2d",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0004",tempString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configDeviceScanFilteringMac:(NSString *)macAddress
                               topic:(NSString *)topic
                              mqttID:(NSString *)mqttID
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@",@"2f",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0000"];
    if (ValidStr(macAddress)) {
        commandData = [NSString stringWithFormat:@"%@%@%@%@",@"2f",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0006",macAddress];
    }
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configRawFilterConditions:(NSArray <id <MKRawFilterProtocol>>*)conditions
                            topic:(NSString *)topic
                           mqttID:(NSString *)mqttID
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (conditions.count > 5) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *contentData = @"";
    for (id <MKRawFilterProtocol>protocol in conditions) {
        if (![self isConfirmRawFilterProtocol:protocol]) {
            [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
            return;
        }
        NSString *minIndex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.minIndex];
        if (minIndex.length == 1) {
            minIndex = [@"0" stringByAppendingString:minIndex];
        }
        NSString *maxIndex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.maxIndex];
        if (maxIndex.length == 1) {
            maxIndex = [@"0" stringByAppendingString:maxIndex];
        }
        NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)(protocol.rawData.length / 2 + 3)];
        if (lenString.length == 1) {
            lenString = [@"0" stringByAppendingString:lenString];
        }
        NSString *conditionString = [NSString stringWithFormat:@"%@%@%@%@%@",lenString,protocol.dataType,minIndex,maxIndex,protocol.rawData];
        contentData = [contentData stringByAppendingString:conditionString];
    }
    NSString *contenLen = [self fourLenHex:(contentData.length / 2)];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"2e",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],contenLen,contentData];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configDeviceDataReportSettingTime:(NSInteger)time
                                    topic:(NSString *)topic
                                   mqttID:(NSString *)mqttID
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock {
    if (time < 0 || time > 60) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *timeString = [NSString stringWithFormat:@"%1lx",(unsigned long)time];
    if (timeString.length == 1) {
        timeString = [@"0" stringByAppendingString:timeString];
    }
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"30",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0001",timeString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}


#pragma mark - update
+ (void)updateFile:(MKUpdateFileType)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
             topic:(NSString *)topic
            mqttID:(NSString *)mqttID
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError *error))failedBlock {
    if (port < 0 || port > 65535 || !catalogue || !host) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_queue_t updateQueue = dispatch_queue_create("ota.com.moko", 0);
    dispatch_async(updateQueue, ^{
        if (![self sendUpdateFileType:fileType topic:topic mqttID:mqttID]) {
            [MKMQTTServerErrorBlockAdopter operationOTAErrorBlock:failedBlock];
            return ;
        }
        if (![self sendUpdateHost:host port:port topic:topic mqttID:mqttID]) {
            [MKMQTTServerErrorBlockAdopter operationOTAErrorBlock:failedBlock];
            return ;
        }
        if (![self sendUpdateCatalogue:catalogue topic:topic mqttID:mqttID]) {
            [MKMQTTServerErrorBlockAdopter operationOTAErrorBlock:failedBlock];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

+ (void)configUpdateFileType:(MKUpdateFileType)fileType
                       topic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *typeString = @"01";
    if (fileType == MKUpdateCAFile) {
        typeString = @"02";
    }else if (fileType == MKUpdateClientCertificate) {
        typeString = @"04";
    }else if (fileType == MKUpdateClientPrivateKey) {
        typeString = @"03";
    }
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"2a",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0001",typeString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configUpdateServerWithHost:(NSString *)host
                              port:(NSInteger)port
                             topic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    if (port < 0 || port > 65535 || !host) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < host.length; i ++) {
        int asciiCode = [host characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *dataLen = [self fourLenHex:(host.length + 2)];
    NSString *portHex = [self fourLenHex:port];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@%@",@"2b",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],dataLen,tempString,portHex];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)configUpdateServerCatalogue:(NSString *)catalogue
                              topic:(NSString *)topic
                             mqttID:(NSString *)mqttID
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    if (!catalogue) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < catalogue.length; i ++) {
        int asciiCode = [catalogue characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *catalogueLen = [self fourLenHex:catalogue.length];
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@%@",@"2c",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],catalogueLen,tempString];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}


#pragma mark - private method
+ (NSString *)fourLenHex:(NSInteger)value {
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)value];
    if (lenString.length == 1) {
        lenString = [@"000" stringByAppendingString:lenString];
    }else if (lenString.length == 2) {
        lenString = [@"00" stringByAppendingString:lenString];
    }else if (lenString.length == 3) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    return lenString;
}

+ (BOOL)isConfirmRawFilterProtocol:(id <MKRawFilterProtocol>)protocol {
    if (![protocol conformsToProtocol:@protocol(MKRawFilterProtocol)]) {
        return NO;
    }
    if (!ValidStr(protocol.dataType) || protocol.dataType.length != 2 || ![protocol.dataType regularExpressions:isHexadecimal]) {
        return NO;
    }
    NSArray *typeList = [self dataTypeList];
    if (![typeList containsObject:[protocol.dataType uppercaseString]]) {
        return NO;
    }
    if (protocol.minIndex == 0 && protocol.maxIndex == 0) {
        if (!ValidStr(protocol.rawData) || protocol.rawData.length > 58 || ![protocol.rawData regularExpressions:isHexadecimal] || (protocol.rawData.length % 2 != 0)) {
            return NO;
        }
        return YES;
    }
    if (protocol.minIndex < 0 || protocol.minIndex > 29 || protocol.maxIndex < 0 || protocol.maxIndex > 29) {
        return NO;
    }
    
    if (protocol.maxIndex < protocol.minIndex) {
        return NO;
    }
    if (!ValidStr(protocol.rawData) || protocol.rawData.length > 58 || ![protocol.rawData regularExpressions:isHexadecimal]) {
        return NO;
    }
    NSInteger totalLen = (protocol.maxIndex - protocol.minIndex + 1) * 2;
    if (protocol.rawData.length != totalLen) {
        return NO;
    }
    return YES;
}

+ (NSArray *)dataTypeList {
    return @[@"01",@"02",@"03",@"04",@"05",
             @"06",@"07",@"08",@"09",@"0A",
             @"0D",@"0E",@"0F",@"10",@"11",
             @"12",@"14",@"15",@"16",@"17",
             @"18",@"19",@"1A",@"1B",@"1C",
             @"1D",@"1E",@"1F",@"20",@"21",
             @"22",@"23",@"24",@"25",@"26",
             @"27",@"28",@"29",@"2A",@"2B",
             @"2C",@"2D",@"3D",@"FF"];
}

#pragma mark - ota private method
+ (BOOL)sendUpdateFileType:(MKUpdateFileType)fileType
                     topic:(NSString *)topic
                    mqttID:(NSString *)mqttID {
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self configUpdateFileType:fileType topic:topic mqttID:mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (BOOL)sendUpdateHost:(NSString *)host
                  port:(NSInteger)port
                 topic:(NSString *)topic
                mqttID:(NSString *)mqttID {
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self configUpdateServerWithHost:host port:port topic:topic mqttID:mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (BOOL)sendUpdateCatalogue:(NSString *)catalogue
                      topic:(NSString *)topic
                     mqttID:(NSString *)mqttID {
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self configUpdateServerCatalogue:catalogue topic:topic mqttID:mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

@end

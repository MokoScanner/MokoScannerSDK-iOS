//
//  MKMQTTServerInterface.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"
#import "MKMQTTServerErrorBlockAdopter.h"
#import "MKMQTTSDKAdopter.h"

@implementation MKMQTTServerInterface

+ (void)resetDeviceWithTopic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    NSString *publishData = [NSString stringWithFormat:@"%@%@%@",@"28",[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"000101"];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:publishData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

+ (void)readDeviceScanStatusWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"17"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDeviceScanIntervalWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"18"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDeviceScanFilteringRssiWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"19"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDeviceScanFilteringNameWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"20"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readCompanyNameWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"12"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDateOfManufactureWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"13"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readProductModeWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"1a"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readFirmwareVersionWithTopic:(NSString *)topic
                              mqttID:(NSString *)mqttID
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"15"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDeviceMacAddressWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"16"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

+ (void)readDeviceNameWithTopic:(NSString *)topic
                         mqttID:(NSString *)mqttID
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    [self publishReadDataWithTopic:topic
                            header:@"14"
                            mqttID:mqttID
                          sucBlock:sucBlock
                       failedBlock:failedBlock];
}

#pragma mark - update

#pragma mark - private method
+ (void)publishReadDataWithTopic:(NSString *)topic
                          header:(NSString *)header
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandData = [NSString stringWithFormat:@"%@%@%@",header,[MKMQTTSDKAdopter fetchDeviceIDMode:mqttID],@"0000"];
    [[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                                topic:topic
                                             sucBlock:sucBlock
                                          failedBlock:failedBlock];
}

@end

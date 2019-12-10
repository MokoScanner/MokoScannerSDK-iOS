//
//  MKMQTTServerInterface+MKConfig.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

typedef NS_ENUM(NSInteger, MKUpdateFileType) {
    MKUpdateFirmware,
    MKUpdateCAFile,
    MKUpdateClientCertificate,
    MKUpdateClientPrivateKey,
};

NS_ASSUME_NONNULL_BEGIN

@interface MKMQTTServerInterface (MKConfig)

/// 设置设备的扫描状态
/// @param isOn YES:打开扫描,NO:关闭扫描
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanStatus:(BOOL)isOn
                         topic:(NSString *)topic
                        mqttID:(NSString *)mqttID
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置设备的扫描间隔
/// @param interval 扫描间隔,10~65535
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanInterval:(NSInteger)interval
                           topic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置设备的扫描间隔
/// @param rssi 扫描过滤rssi
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanFilteringRssi:(NSInteger)rssi
                                topic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置设备的扫描间隔
/// @param filteringName 扫描过滤名称
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanFilteringName:(NSString *)filteringName
                                topic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

#pragma mark - update
/**
Device OTA upgrade

@param fileType file type
@param host The IP address or domain name of the new firmware host
@param port Range£∫0~65535
@param catalogue The length is less than 100 bytes
@param topic update file topic
@param mqttID mqttID
@param sucBlock Success callback
@param failedBlock Failed callback
*/
+ (void)updateFile:(MKUpdateFileType)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
             topic:(NSString *)topic
            mqttID:(NSString *)mqttID
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError *error))failedBlock;

/// OTA Type
/// @param fileType file type
/// @param topic update file topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configUpdateFileType:(MKUpdateFileType)fileType
                       topic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Device OTA upgrade
/// @param host The IP address or domain name of the new firmware host
/// @param port Range£∫0~65535
/// @param topic update file topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configUpdateServerWithHost:(NSString *)host
                              port:(NSInteger)port
                             topic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// OTA catalogue
/// @param catalogue The length is less than 100 bytes
/// @param topic update file topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configUpdateServerCatalogue:(NSString *)catalogue
                              topic:(NSString *)topic
                             mqttID:(NSString *)mqttID
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END

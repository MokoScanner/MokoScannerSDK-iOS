//
//  MKMQTTServerInterface+MKConfig.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MKUpdateFileType) {
    MKUpdateFirmware,
    MKUpdateCAFile,
    MKUpdateClientCertificate,
    MKUpdateClientPrivateKey,
};

@protocol MKLEDSettingProtocol <NSObject>

@property (nonatomic, assign)BOOL serverConnectingIson;

@property (nonatomic, assign)BOOL serverConnectedIson;

@property (nonatomic, assign)BOOL bleBroadcastIson;

@property (nonatomic, assign)BOOL bleConnectingIson;

@end

@protocol MKRawFilterProtocol <NSObject>

/// 参考https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile/
@property (nonatomic, copy)NSString *dataType;

@property (nonatomic, assign)NSInteger minIndex;

@property (nonatomic, assign)NSInteger maxIndex;

@property (nonatomic, copy)NSString *rawData;

@end

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

/// 设置设备的扫描过滤rssi
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

/// 设置设备的扫描过滤名称
/// @param filteringName 扫描过滤名称,1~29字符
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanFilteringName:(NSString *)filteringName
                                topic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;


/// 配置指示灯状态
/// @param protocol protocol
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configLEDSettings:(id <MKLEDSettingProtocol>)protocol
                    topic:(NSString *)topic
                   mqttID:(NSString *)mqttID
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置扫描过滤的mac地址
/// @param macAddress mac地址
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceScanFilteringMac:(NSString *)macAddress
                               topic:(NSString *)topic
                              mqttID:(NSString *)mqttID
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置raw过滤数据规则
/// @param conditions conditions,最多五组,如果数组里面没有条件，则认为关闭过滤
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configRawFilterConditions:(NSArray <id <MKRawFilterProtocol>>*)conditions
                            topic:(NSString *)topic
                           mqttID:(NSString *)mqttID
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置数据超时时长
/// @param time 0~60
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)configDeviceDataReportSettingTime:(NSInteger)time
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

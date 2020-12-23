//
//  MKBLESDKInterface.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKBLESDKDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mqttServerConnectMode) {
    mqttServerConnectTCPMode,           //The MQTT server connection mode configured for the plug is TCP
    mqttServerConnectOneWaySSLMode,     //The MQTT server connection mode configured for the plug is SSL
    mqttServerConnectTwoWaySSLMode,
};

//Quality of MQQT service
typedef NS_ENUM(NSInteger, mqttServerQosMode) {
    mqttQosLevelAtMostOnce,      //At most once. The message sender to find ways to send messages, but an accident and will not try again.
    mqttQosLevelAtLeastOnce,     //At least once.If the message receiver does not know or the message itself is lost, the message sender sends it again to ensure that the message receiver will receive at least one, and of course, duplicate the message.
    mqttQosLevelExactlyOnce,     //Exactly once.Ensuring this semantics will reduce concurrency or increase latency, but level 2 is most appropriate when losing or duplicating messages is unacceptable.
};

@interface MKBLESDKInterface : NSObject


#pragma mark - interface
/**
 配置服务器地址
 
 @param host host
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configServerHost:(NSString *)host
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置服务器port

 @param port port，范围0~65535
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configServerPort:(NSInteger)port
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置服务器是否清除session

 @param clean YES:清除，NO:保留
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configServerCleanSession:(BOOL)clean
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 配置DeviceID

 @param deviceID APP给设备指定的唯一标识,长度1~32
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDeviceID:(NSString *)deviceID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 配置clientID

 @param clientID clientID,长度1~64
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configClientID:(NSString *)clientID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置服务器用户名，注意，如果服务器不需要通过用户名+密码这种形式验证，则可以为空

 @param userName 用户名，长度0~255
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configUserName:(NSString *)userName
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置服务器密码，注意，如果服务器不需要通过用户名+密码这种形式验证，则可以为空

 @param password password
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configPassword:(NSString *)password
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 配置服务器KeepAlive

 @param keepAlive 单位s，0~120
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configKeepAlive:(NSInteger)keepAlive
               sucBlock:(mk_communicationSuccessBlock)sucBlock
            failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置服务器消息级别

 @param qosMode qosMode
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configQos:(mqttServerQosMode)qosMode
         sucBlock:(mk_communicationSuccessBlock)sucBlock
      failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Connection mode 0: TCP,1: ssl one way,2:ssl two way

 @param connectMode Connection mode 0: TCP,1: ssl one way,2:ssl two way
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configConnectMode:(mqttServerConnectMode)connectMode
                 sucBlock:(mk_communicationSuccessBlock)sucBlock
              failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置CA证书

 @param caFile CA证书
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configCAFile:(NSData *)caFile
            sucBlock:(mk_communicationSuccessBlock)sucBlock
         failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置客户端证书

 @param cert 客户端证书
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configClientCert:(NSData *)cert
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 配置客户端私钥

 @param privateKey 客户端私钥
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configClientPrivateKey:(NSData *)privateKey
                      sucBlock:(mk_communicationSuccessBlock)sucBlock
                   failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 配置设备发布主题

 @param publishTopic 发布主题,长度1~128
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDevicePublishTopic:(NSString *)publishTopic
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 配置设备订阅主题

 @param subscibeTopic 订阅主题，长度1~128
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDeviceSubscibeTopic:(NSString *)subscibeTopic
                         sucBlock:(mk_communicationSuccessBlock)sucBlock
                      failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 设置联网wifi

 @param wifiSSID ssid，长度 1~100
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configWifiSSID:(NSString *)wifiSSID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 设置wifi密码

 @param password 密码，长度 1~100
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configWifiPassword:(NSString *)password
                  sucBlock:(mk_communicationSuccessBlock)sucBlock
               failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 设备发起连接服务器

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDeviceConnectServerWithSucBlock:(mk_communicationSuccessBlock)sucBlock
                                  failedBlock:(mk_communicationFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END

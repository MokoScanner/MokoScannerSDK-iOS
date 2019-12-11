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
 Config server host
 
 @param host Host ip address
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configServerHost:(NSString *)host
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Config server port

 @param port port，port range (0~65535)
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configServerPort:(NSInteger)port
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Whether to clean the session

 @param clean NO: means to create a persistent session, which remains and saves the offline message until the session expires when the client is disconnected.YES: means to create a new temporary session, which is automatically destroyed when the client disconnects.
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configServerCleanSession:(BOOL)clean
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 The only identification number, equipment configuration equipment MQTT communication inside when submitted to MQTT server data will return the id, multiple devices, which is can be used as the equipment of the data returned.

 @param deviceID range 0~32
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configDeviceID:(NSString *)deviceID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 The MQTT server USES the plug as the clientID to distinguish between different plug devices, and if the item is empty, the plug will by default communicate with the MQTT server using the MAC address as the clientID.Device MAC addresses are recommended.length 0~64

 @param clientID clientID,length 0~64
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configClientID:(NSString *)clientID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Configure the server user name. Note that if the server does not require user name + password authentication, it can be left blank.

 @param userName 0~255
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configUserName:(NSString *)userName
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Configure the server user name. Note that if the server does not require user name + password authentication, it can be left blank.

 @param password password
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configPassword:(NSString *)password
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 heartbeat package time, the range is 10~120, and unitis °∞s°±

 @param keepAlive heartbeat package time, the range is 10~120, and unitis °∞s°±
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configKeepAlive:(NSInteger)keepAlive
               sucBlock:(mk_communicationSuccessBlock)sucBlock
            failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 quality of service

 @param qosMode qosMode
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configQos:(mqttServerQosMode)qosMode
         sucBlock:(mk_communicationSuccessBlock)sucBlock
      failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Connection mode 0: TCP,1: ssl one way,2:ssl two way

 @param connectMode Connection mode 0: TCP,1: ssl one way,2:ssl two way
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configConnectMode:(mqttServerConnectMode)connectMode
                 sucBlock:(mk_communicationSuccessBlock)sucBlock
              failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Config CA File

 @param caFile CA file
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configCAFile:(NSData *)caFile
            sucBlock:(mk_communicationSuccessBlock)sucBlock
         failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Config client certificate

 @param cert client certificate
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configClientCert:(NSData *)cert
                sucBlock:(mk_communicationSuccessBlock)sucBlock
             failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 Config client private key

 @param privateKey client private key
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configClientPrivateKey:(NSData *)privateKey
                      sucBlock:(mk_communicationSuccessBlock)sucBlock
                   failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Config publish topic

 @param publishTopic Publish Topic，1~128
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configDevicePublishTopic:(NSString *)publishTopic
                        sucBlock:(mk_communicationSuccessBlock)sucBlock
                     failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 Config subscribe topic

 @param subscibeTopic Subscribe Topic ,1~128
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configDeviceSubscibeTopic:(NSString *)subscibeTopic
                         sucBlock:(mk_communicationSuccessBlock)sucBlock
                      failedBlock:(mk_communicationFailedBlock)failedBlock;
/**
 The phone specifies the specific ssid WiFi network to the plug.

 @param wifiSSID ssid， 1~100
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configWifiSSID:(NSString *)wifiSSID
              sucBlock:(mk_communicationSuccessBlock)sucBlock
           failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 The phone specifies the specific ssid WiFi network to the plug.

 @param password Wifi password, no password required wifi network, password can be blank
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configWifiPassword:(NSString *)password
                  sucBlock:(mk_communicationSuccessBlock)sucBlock
               failedBlock:(mk_communicationFailedBlock)failedBlock;

/**
 Connect server

 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configDeviceConnectServerWithSucBlock:(mk_communicationSuccessBlock)sucBlock
                                  failedBlock:(mk_communicationFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END

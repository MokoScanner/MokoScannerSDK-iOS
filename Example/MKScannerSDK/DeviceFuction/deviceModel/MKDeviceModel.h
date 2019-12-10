//
//  MKDeviceModel.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceNormalDefines.h"

@interface MKDeviceModel : NSObject<MKDeviceModelProtocol>

/**
 进行MQTT通信的时候，设备身份唯一识别码
 */
@property (nonatomic, copy)NSString *mqttID;

@property (nonatomic, copy)NSString *clientID;

/**
 设备广播名字
 */
@property (nonatomic, copy)NSString *device_name;

/**
 订阅主题
 */
@property (nonatomic, copy)NSString *subscribedTopic;

/**
 发布主题
 */
@property (nonatomic, copy)NSString *publishedTopic;

/**
 蓝牙设备的uuid
 */
@property (nonatomic, copy)NSString *deviceUUID;

/**
 智能插座当前设备的状态，离线、开、关
 */
@property (nonatomic, assign)MKBLEGatewayState plugState;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKDeviceModelDelegate>delegate;

/**
 当前model的订阅主题，当用户设置了app的订阅主题时，返回设置的订阅主题，否则返回当前model的订阅主题
 
 @return subscribedTopic
 */
- (NSString *)currentSubscribedTopic;

/**
 当前model的发布主题，当用户设置了app的发布主题时，返回设置的发布主题，否则返回当前model的发布主题
 
 @return publishedTopic
 */
- (NSString *)currentPublishedTopic;

@end

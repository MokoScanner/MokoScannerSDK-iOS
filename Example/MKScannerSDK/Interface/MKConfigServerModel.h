//
//  MKConfigServerModel.h
//  MKBLEGateway
//
//  Created by aa on 2019/7/22.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConfigServerModel : NSObject

/**
 设备跟MQTT通信时s唯一的通信ID
 */
@property (nonatomic, copy)NSString *mqttID;

/**
 主机
 */
@property (nonatomic, copy)NSString *host;

/**
 端口号
 */
@property (nonatomic, copy)NSString *port;

/**
 是否是清除session，默认yes
 */
@property (nonatomic, assign)BOOL cleanSession;

/**
 0:TCP，1:one-way SSL,2:two-way SSl
 */
@property (nonatomic, assign)NSInteger connectMode;

/**
 qos
 */
@property (nonatomic, copy)NSString *qos;

/**
 活跃时间
 */
@property (nonatomic, copy)NSString *keepAlive;

/**
 客户端id
 */
@property (nonatomic, copy)NSString *clientId;

/**
 用户名
 */
@property (nonatomic, copy)NSString *userName;

/**
 密码
 */
@property (nonatomic, copy)NSString *password;

/**
 CA证书名字
 */
@property (nonatomic, copy)NSString *caFileName;

/**
 App客户端使用的是P12证书
 */
@property (nonatomic, copy)NSString *clientP12CertName;

/**
 客户端私钥
 */
@property (nonatomic, copy)NSString *clientKeyName;

/**
 客户端证书名字
 */
@property (nonatomic, copy)NSString *clientCertName;

/**
 订阅主题
 */
@property (nonatomic, copy)NSString *subscribedTopic;

/**
 发布主题
 */
@property (nonatomic, copy)NSString *publishedTopic;

/**
 必须的值是否都有了，host、port、qos、keep alive
 
 @return YES：必须参数都有了
 */
- (BOOL)needParametersHasValue;

/**
 更新属性值
 
 @param dic dic
 */
- (void)updateServerModelWithDic:(NSDictionary *)dic;

- (void)updateServerDataWithModel:(MKConfigServerModel *)model;

@end

NS_ASSUME_NONNULL_END

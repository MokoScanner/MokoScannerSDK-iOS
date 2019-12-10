//
//  MKConfigServerModel.m
//  MKBLEGateway
//
//  Created by aa on 2019/7/22.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKConfigServerModel.h"

@implementation MKConfigServerModel

- (instancetype)init{
    if (self = [super init]) {
        self.cleanSession = YES;
    }
    return self;
}

/**
 必须的值是否都有了，host、port、qos、keep alive
 
 @return YES：必须参数都有了
 */
- (BOOL)needParametersHasValue{
    if (!ValidStr(self.host)
        || !ValidStr(self.port)
        || !ValidStr(self.qos)
        || !ValidStr(self.keepAlive)) {
        return NO;
    }
    return YES;
}

/**
 更新属性值
 
 @param dic dic
 */
- (void)updateServerModelWithDic:(NSDictionary *)dic{
    if (!ValidDict(dic)) {
        return;
    }
    if (ValidStr(dic[@"host"])) {
        self.host = dic[@"host"];
    }
    if (ValidStr(dic[@"port"])) {
        self.port = dic[@"port"];
    }
    self.cleanSession = [dic[@"cleanSession"] boolValue];
    self.connectMode = [dic[@"connectMode"] integerValue];
    if (ValidStr(dic[@"qos"])) {
        self.qos = dic[@"qos"];
    }
    if (ValidStr(dic[@"keepAlive"])) {
        self.keepAlive = dic[@"keepAlive"];
    }
    if (ValidStr(dic[@"clientId"])) {
        self.clientId = dic[@"clientId"];
    }
    if (ValidStr(dic[@"userName"])) {
        self.userName = dic[@"userName"];
    }
    if (ValidStr(dic[@"password"])) {
        self.password = dic[@"password"];
    }
    if (ValidStr(dic[@"caFileName"])) {
        self.caFileName = dic[@"caFileName"];
    }
    if (ValidStr(dic[@"clientP12CertName"])) {
        self.clientP12CertName = dic[@"clientP12CertName"];
    }
    if (ValidStr(dic[@"clientKeyName"])) {
        self.clientKeyName = dic[@"clientKeyName"];
    }
    if (ValidStr(dic[@"clientCertName"])) {
        self.clientCertName = dic[@"clientCertName"];
    }
    if (ValidStr(dic[@"subscribedTopic"])) {
        self.subscribedTopic = dic[@"subscribedTopic"];
    }
    if (ValidStr(dic[@"publishedTopic"])) {
        self.publishedTopic = dic[@"publishedTopic"];
    }
    if (ValidStr(dic[@"mqttID"])) {
        self.mqttID = dic[@"mqttID"];
    }
}

- (void)updateServerDataWithModel:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    self.host = model.host;
    self.port = model.port;
    self.cleanSession = model.cleanSession;
    self.connectMode = model.connectMode;
    self.qos = model.qos;
    self.keepAlive = model.keepAlive;
    self.clientId = model.clientId;
    self.userName = model.userName;
    self.password = model.password;
    self.caFileName = model.caFileName;
    self.clientP12CertName = model.clientP12CertName;
    self.clientKeyName = model.clientKeyName;
    self.clientCertName = model.clientCertName;
    self.subscribedTopic = model.subscribedTopic;
    self.publishedTopic = model.publishedTopic;
    self.mqttID = model.mqttID;
}

@end

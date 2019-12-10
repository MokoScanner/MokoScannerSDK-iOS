//
//  MKMQTTServerDataManager.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMQTTServerDataDefines.h"

/*
 mqtt服务器连接状态改变
 */
extern NSString *const MKMQTTSessionManagerStateChangedNotification;

@class MKConfigServerModel;
@interface MKMQTTServerDataManager : NSObject

@property (nonatomic, strong, readonly)MKConfigServerModel *configServerModel;

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState state;

+ (MKMQTTServerDataManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接mqtt server

 */
- (void)connectServer;

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData;

@end

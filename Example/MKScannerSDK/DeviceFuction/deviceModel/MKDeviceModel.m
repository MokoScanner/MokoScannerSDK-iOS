//
//  MKDeviceModel.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel()

/**
 超过40s没有接收到信息，则认为离线
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

/**
 是否处于离线状态
 */
@property (nonatomic, assign)BOOL offline;

@end

@implementation MKDeviceModel

- (void)dealloc{
    NSLog(@"MKDeviceModel销毁");
}

#pragma mark - MKDeviceModelProtocol

- (void)updatePropertyWithModel:(MKDeviceModel *)model{
    if (!model) {
        return;
    }
    self.device_name = model.device_name;
    self.clientID = model.clientID;
    self.subscribedTopic = model.subscribedTopic;
    self.publishedTopic = model.publishedTopic;
    self.mqttID = model.mqttID;
    self.deviceUUID = model.deviceUUID;
    self.plugState = model.plugState;
}

- (void)startStateMonitoringTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.offline = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 62.f) {
            //接受数据超时
            dispatch_cancel(weakSelf.receiveTimer);
            weakSelf.receiveTimerCount = 0;
            weakSelf.offline = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(deviceModelStateChanged:)]) {
                    [weakSelf.delegate deviceModelStateChanged:weakSelf];
                }
            });
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter{
    if (self.offline) {
        //已经离线，重新开启定时器监测
        [self startStateMonitoringTimer];
        return;
    }
    self.receiveTimerCount = 0;
}

/**
 取消定时器
 */
- (void)cancel{
    self.receiveTimerCount = 0;
    self.offline = NO;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
}

- (NSString *)currentSubscribedTopic {
    if (ValidStr([MKMQTTServerDataManager sharedInstance].configServerModel.publishedTopic)) {
        return [MKMQTTServerDataManager sharedInstance].configServerModel.publishedTopic;
    }
    return self.subscribedTopic;
}

- (NSString *)currentPublishedTopic {
    if (ValidStr([MKMQTTServerDataManager sharedInstance].configServerModel.subscribedTopic)) {
        return [MKMQTTServerDataManager sharedInstance].configServerModel.subscribedTopic;
    }
    return self.publishedTopic;
}

@end

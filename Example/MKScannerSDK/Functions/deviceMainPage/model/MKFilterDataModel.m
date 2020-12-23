//
//  MKFilterDataModel.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterDataModel.h"

#import "MKFilterRawDataCellModel.h"

@interface MKRawFilterProtocolModel : NSObject<MKRawFilterProtocol>

@property (nonatomic, copy)NSString *dataType;

@property (nonatomic, assign)NSInteger minIndex;

@property (nonatomic, assign)NSInteger maxIndex;

@property (nonatomic, copy)NSString *rawData;

@end

@implementation MKRawFilterProtocolModel

@end

@interface MKFilterDataModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, copy)NSString *mqttID;

@property (nonatomic, copy)NSString *topic;

@end

@implementation MKFilterDataModel

- (void)configDataWithRawConditons:(NSArray<MKFilterRawDataCellModel *> *)conditions
                            mqttID:(NSString *)mqttID
                             topic:(NSString *)topic
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    self.mqttID = nil;
    self.mqttID = mqttID;
    self.topic = nil;
    self.topic = topic;
    dispatch_async(self.configQueue, ^{
        if (![self validParams:conditions]) {
            [self operationFailedBlockWithMsg:@"Params error" block:failedBlock];
            return ;
        }
        if (![self configFilterRssi]) {
            [self operationFailedBlockWithMsg:@"Config rssi error" block:failedBlock];
            return;
        }
        if (![self configFilterName]) {
            [self operationFailedBlockWithMsg:@"Config name error" block:failedBlock];
            return;
        }
        if (![self configFilterMac]) {
            [self operationFailedBlockWithMsg:@"Config mac error" block:failedBlock];
            return;
        }
        if (![self configRawFilterData:conditions]) {
            [self operationFailedBlockWithMsg:@"Config raw error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            sucBlock();
        });
    });
}

#pragma mark - interface
- (BOOL)configFilterRssi {
    __block BOOL success = NO;
    [MKMQTTServerInterface configDeviceScanFilteringRssi:self.filterRssi topic:self.topic mqttID:self.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configFilterName {
    __block BOOL success = NO;
    NSString *nameFilter = (self.nameFilterIsOn ? self.nameFilter : @"");
    [MKMQTTServerInterface configDeviceScanFilteringName:nameFilter topic:self.topic mqttID:self.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configFilterMac {
    __block BOOL success = NO;
    NSString *macFilter = (self.macFilterIsOn ? self.macFilter : @"");
    [MKMQTTServerInterface configDeviceScanFilteringMac:macFilter topic:self.topic mqttID:self.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configRawFilterData:(NSArray<MKFilterRawDataCellModel *> *)conditions {
    __block BOOL success = NO;
    NSMutableArray *list = [NSMutableArray array];
    if (self.filterRawDataIsOn) {
        for (NSInteger i = 0 ; i < conditions.count; i ++) {
            MKFilterRawDataCellModel *tempModel = conditions[i];
            MKRawFilterProtocolModel *protocolModel = [[MKRawFilterProtocolModel alloc] init];
            protocolModel.dataType = tempModel.dataType;
            protocolModel.minIndex = (ValidStr(tempModel.minIndex) ? [tempModel.minIndex integerValue] : 0);
            protocolModel.maxIndex = (ValidStr(tempModel.maxIndex) ? [tempModel.maxIndex integerValue] : 0);
            protocolModel.rawData = tempModel.rawData;
            [list addObject:protocolModel];
        }
    }
    [MKMQTTServerInterface configRawFilterConditions:list topic:self.topic mqttID:self.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method

- (BOOL)validParams:(NSArray<MKFilterRawDataCellModel *> *)conditions {
    if (self.nameFilterIsOn && !ValidStr(self.nameFilter)) {
        return NO;
    }
    if (self.macFilterIsOn && (!ValidStr(self.macFilter) || ![self.macFilter regularExpressions:isHexadecimal] || self.macFilter.length != 12)) {
        return NO;
    }
    if (!self.filterRawDataIsOn) {
        return YES;
    }
    if (conditions.count == 0) {
        return NO;
    }
    for (MKFilterRawDataCellModel *model in conditions) {
        if (![model validParamsSuccess]) {
            return NO;
        }
    }
    return YES;
}

- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"filterParams"
                                                    code:-999
                                                userInfo:@{@"errorInfo":SafeStr(msg)}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("com.moko.configFilterQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

@end

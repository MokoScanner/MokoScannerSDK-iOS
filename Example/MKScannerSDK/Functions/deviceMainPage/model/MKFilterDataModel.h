//
//  MKFilterDataModel.h
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKFilterRawDataCellModel;
@interface MKFilterDataModel : NSObject

@property (nonatomic, assign)NSInteger filterRssi;

@property (nonatomic, assign)BOOL nameFilterIsOn;

@property (nonatomic, copy)NSString *nameFilter;

@property (nonatomic, assign)BOOL macFilterIsOn;

@property (nonatomic, copy)NSString *macFilter;

@property (nonatomic, assign)BOOL filterRawDataIsOn;

/// 配置参数
/// @param conditions 注意，当filterRawDataIsOn=YES的时候conditions一定不能为空，否则报错，当filterRawDataIsOn=NO的时候就不再校验conditions
/// @param mqttID mqttID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)configDataWithRawConditons:(nullable NSArray <MKFilterRawDataCellModel *>*)conditions
                            mqttID:(NSString *)mqttID
                             topic:(NSString *)topic
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END

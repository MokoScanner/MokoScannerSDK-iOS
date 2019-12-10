//
//  MKAddDeviceDataManager.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;
@interface MKAddDeviceDataManager : NSObject

@property (nonatomic, strong)MKConfigServerModel *serverModel;

@property (nonatomic, strong)NSDictionary *deviceParams;

+ (MKAddDeviceDataManager *)addDeviceManager;

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock;

@end

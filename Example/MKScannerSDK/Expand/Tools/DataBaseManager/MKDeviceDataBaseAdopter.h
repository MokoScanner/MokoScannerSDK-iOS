//
//  MKDeviceDataBaseAdopter.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDeviceDataBaseAdopter : NSObject

+ (void)operationInsertFailedBlock:(void (^)(NSError *error))block;

+ (void)operationUpdateFailedBlock:(void (^)(NSError *error))block;

+ (void)operationDeleteFailedBlock:(void (^)(NSError *error))block;

+ (void)operationGetDataFailedBlock:(void (^)(NSError *error))block;

@end

//
//  MKTaskDataAdopter.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBCharacteristic;
@interface MKTaskDataAdopter : NSObject

+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END

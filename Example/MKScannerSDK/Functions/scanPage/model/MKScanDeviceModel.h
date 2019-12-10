//
//  MKScanDeviceModel.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CBPeripheral;
@interface MKScanDeviceModel : NSObject

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *rssi;

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END

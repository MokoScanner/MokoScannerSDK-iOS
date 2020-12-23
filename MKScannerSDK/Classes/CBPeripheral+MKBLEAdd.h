//
//  CBPeripheral+MKBLEAdd.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "MKBLESDKDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKBLEAdd)

@property (nonatomic, strong, readonly)CBCharacteristic *dataCharacteristic;

- (void)updateCharacterWithService:(CBService *)service;

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)connectSuccess;

- (void)setNil;

@end

NS_ASSUME_NONNULL_END

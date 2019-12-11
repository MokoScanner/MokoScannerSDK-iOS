//
//  CBPeripheral+MKBLEAdd.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "CBPeripheral+MKBLEAdd.h"
#import <objc/runtime.h>

static const char *dataCharacteristicKey = "dataCharacteristicKey";

static const char *dataCharacteristicNotifySuccessKey = "dataCharacteristicNotifySuccessKey";

@implementation CBPeripheral (MKBLEAdd)

- (void)updateCharacterWithService:(CBService *)service {
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"FF19"]]) {
        return;
    }
    NSArray *charactList = [service.characteristics mutableCopy];
    for (CBCharacteristic *characteristic in charactList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
            objc_setAssociatedObject(self, &dataCharacteristicKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
            break;
        }
    }
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
        objc_setAssociatedObject(self, &dataCharacteristicNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setNil {
    objc_setAssociatedObject(self, &dataCharacteristicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &dataCharacteristicNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)connectSuccess {
    if (!self.dataCharacteristic) {
        return NO;
    }
    NSNumber *notifyData = objc_getAssociatedObject(self, &dataCharacteristicNotifySuccessKey);
    if (!notifyData || ![notifyData boolValue]) {
        return NO;
    }
    return YES;
}

- (CBCharacteristic *)dataCharacteristic {
    return objc_getAssociatedObject(self, &dataCharacteristicKey);
}

@end

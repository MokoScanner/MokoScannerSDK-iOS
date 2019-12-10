//
//  MKDeviceBLEConfigManager.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/17.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKDeviceBLEConfigManager : NSObject

- (void)configDeviceDataWithWifiSSID:(NSString *)wifiSSID
                        wifiPassword:(NSString *)wifiPassword
                          peripheral:(CBPeripheral *)peripheral
                         serverModel:(MKConfigServerModel *)serverModel
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END

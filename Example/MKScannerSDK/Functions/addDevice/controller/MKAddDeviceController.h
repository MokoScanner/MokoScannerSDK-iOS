//
//  MKAddDeviceController.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseViewController.h"

@class CBPeripheral;
@interface MKAddDeviceController : MKBaseViewController<addDeviceControllerConfigProtocol>

@property (nonatomic, strong)MKConfigServerModel *configModel;

@property (nonatomic, strong)NSDictionary *deviceParams;

@end

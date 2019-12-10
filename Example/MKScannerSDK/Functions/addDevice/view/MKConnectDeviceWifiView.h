//
//  MKConnectDeviceWifiView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConnectViewProtocol.h"

@interface MKConnectDeviceWifiView : UIView<MKConnectViewProtocol>

@property (nonatomic, weak)id <MKConnectViewConfirmDelegate>delegate;

@end

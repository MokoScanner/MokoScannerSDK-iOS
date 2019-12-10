//
//  MKAddDeviceView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKAddDeviceView : UIView

@property (nonatomic, copy)void (^addDeviceBlock)(void);

@end

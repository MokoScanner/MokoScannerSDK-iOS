//
//  MKConnectDeviceProgressView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConnectViewProtocol.h"

@interface MKConnectDeviceProgressView : UIView<MKConnectViewProtocol>

@property (nonatomic, weak)id <MKConnectViewConfirmDelegate>delegate;

- (void)setProgress:(CGFloat)progress duration:(CGFloat)duration;

- (CGFloat)currentProgress;

@end

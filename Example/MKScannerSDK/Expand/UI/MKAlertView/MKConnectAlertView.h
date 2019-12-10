//
//  MKConnectAlertView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConnectAlertView : UIView

@property (nonatomic, strong, readonly)UILabel *titleLabel;

- (instancetype)initWithTitleMsg:(NSString *)titleMsg
                    cancelAction:(void (^)(void))cancelAction
                   confirmAction:(void (^)(void))confirmAction;

- (instancetype)initWithTitleMsg:(NSString *)titleMsg
              confirmButtonTitle:(NSString *)confirmTitle
               cancelButtonTitle:(NSString *)cancelTitle
                    cancelAction:(void (^)(void))cancelAction
                   confirmAction:(void (^)(void))confirmAction;

@end

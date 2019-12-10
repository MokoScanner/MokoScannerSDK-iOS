//
//  MKModifyLocalNameView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKModifyLocalNameView : UIView

- (void)showConnectAlertViewTitle:(NSString *)titleMsg text:(NSString *)text block:(void (^)(BOOL empty,NSString *name))block;

@end

//
//  MKCommonlyUIHelper.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MKCommonlyUIHelper : NSObject

/**
 背景颜色为导航栏颜色、根据屏幕宽度自适应宽度、圆角弧度为5.f的按钮
 
 @param title 按钮的title
 @param target 按钮所在的父容器
 @param action 按钮关联的方法
 @return button
 */
+ (UIButton *)commonBottomButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
/**
 带有超链接样式的可点击的label，注意，为了UI美观，需要动态计算label文字的宽度，然后设置label的frame，防止底部线条过长
 
 @param text label的text
 @param textColor label的标题颜色
 @param target label所在的父容器
 @param action label关联的方法
 @return label
 */
+ (UILabel *)clickEnableLabelWithText:(NSString *)text textColor:(UIColor *)textColor target:(id)target action:(SEL)action;

/**
 带圆角边框的输入框,并且最大输入长度为32个字符
 
 @return UITextField
 */
+ (UITextField *)configServerTextField;

@end

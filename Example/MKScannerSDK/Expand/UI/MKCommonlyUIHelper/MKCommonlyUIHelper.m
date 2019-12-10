/*
    项目里面一些常用的UI控件
 */

#import "MKCommonlyUIHelper.h"

@implementation MKCommonlyUIHelper

/**
 背景颜色为导航栏颜色、根据屏幕宽度自适应宽度、圆角弧度为5.f的按钮

 @param title 按钮的title
 @param target 按钮所在的父容器
 @param action 按钮关联的方法
 @return button
 */
+ (UIButton *)commonBottomButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action{
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton setBackgroundColor:UIColorFromRGB(0x0188cc)];
    [bottomButton.titleLabel setFont:MKFont(18.f)];
    [bottomButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [bottomButton setTitle:title forState:UIControlStateNormal];
    [bottomButton.layer setMasksToBounds:YES];
    [bottomButton.layer setCornerRadius:5.f];
    [bottomButton addTapAction:target selector:action];
    return bottomButton;
}

/**
 带有超链接样式的可点击的label，注意，为了UI美观，需要动态计算label文字的宽度，然后设置label的frame，防止底部线条过长

 @param text label的text
 @param textColor label的标题颜色
 @param target label所在的父容器
 @param action label关联的方法
 @return label
 */
+ (UILabel *)clickEnableLabelWithText:(NSString *)text textColor:(UIColor *)textColor target:(id)target action:(SEL)action{
    UILabel *linkLabel = [[UILabel alloc] init];
    linkLabel.textColor = textColor;
    linkLabel.textAlignment = NSTextAlignmentCenter;
    linkLabel.font = (iPhone6Plus ? MKFont(17) : MKFont(16));
    linkLabel.numberOfLines = 0;
    linkLabel.text = text;
    [linkLabel addTapAction:target selector:action];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = textColor;
    [linkLabel addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
    return linkLabel;
}

/**
 带圆角边框的输入框,并且最大输入长度为32个字符

 @return UITextField
 */
+ (UITextField *)configServerTextField{
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:normalInput];
    textField.backgroundColor = COLOR_WHITE_MACROS;
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = MKFont(15.f);
    
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
    textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
    textField.layer.cornerRadius = 5.f;
    
//    textField.maxLength = 32;
    return textField;
}

@end

//
//  MKModifyLocalNameView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKModifyLocalNameView.h"
#import "MKConnectAlertView.h"

static CGFloat const offset_X = 15.f;
static CGFloat const alertViewHeight = 190.f;

@interface MKModifyLocalNameView()

@property (nonatomic, strong)MKConnectAlertView *alertView;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, copy)void (^confirmBlock)(BOOL empty, NSString *name);

@end

@implementation MKModifyLocalNameView

- (void)dealloc{
    NSLog(@"MKModifyLocalNameView销毁");
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        [self setBackgroundColor:RGBCOLOR(102, 102, 102)];
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.textField];
        [self addTapAction:self selector:@selector(dismiss)];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_right).mas_offset(37.f);
        make.width.mas_equalTo(self.frame.size.width - 2 * 37.f);
        make.top.mas_equalTo(152.f);
        make.height.mas_equalTo(alertViewHeight);
    }];
    CGFloat width = self.frame.size.width - 2 * 37.f;
    //注意这个，alertView上面的title会自动换行，所以需要动态计算postion_Y
    CGSize titleSize = [NSString sizeWithText:self.alertView.titleLabel.text
                                      andFont:self.alertView.titleLabel.font
                                   andMaxSize:CGSizeMake(width - 2 * offset_X, MAXFLOAT)];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(titleSize.height + 20.f + 30.f);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - event method
- (void)confirmButtonPressed{
    NSString *name = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!ValidStr(name)) {
        if (self.confirmBlock) {
            self.confirmBlock(YES, nil);
        }
        return;
    }
    if (self.confirmBlock) {
        self.confirmBlock(NO,name);
    }
    [self dismiss];
}

- (void)cancelButtonPressed{
    [self dismiss];
}

#pragma mark - public method
- (void)showConnectAlertViewTitle:(NSString *)titleMsg text:(NSString *)text block:(void (^)(BOOL empty, NSString *name))block{
    self.confirmBlock = nil;
    self.confirmBlock = block;
    [kAppWindow addSubview:self];
    [self.textField becomeFirstResponder];
    if (ValidStr(titleMsg)) {
        self.alertView.titleLabel.text = titleMsg;
    }
    if (ValidStr(text)) {
        self.textField.text = text;
    }
    [UIView animateWithDuration:.3f animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(-kScreenWidth, 0);
    }];
}

#pragma mark - - (void)dismiss{
- (void)dismiss{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - setter & getter
- (MKConnectAlertView *)alertView{
    if (!_alertView) {
        WS(weakSelf);
        _alertView = [[MKConnectAlertView alloc] initWithTitleMsg:@"" confirmButtonTitle:@"Save" cancelButtonTitle:@"Cancel" cancelAction:^{
            [weakSelf cancelButtonPressed];
        } confirmAction:^{
            [weakSelf confirmButtonPressed];
        }];
    }
    return _alertView;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [MKCommonlyUIHelper configServerTextField];
        _textField.maxLength = 20;
    }
    return _textField;
}


@end

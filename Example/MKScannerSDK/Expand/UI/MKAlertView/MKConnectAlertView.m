//
//  MKConnectAlertView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConnectAlertView.h"

@interface MKConnectAlertView()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UIView *horizontalLine;

@property (nonatomic, strong)UIView *verticalLine;

@property (nonatomic, strong)UIButton *cancelButton;

@property (nonatomic, strong)UIButton *confirmButton;

@property (nonatomic, copy)void (^cancelAction)(void);

@property (nonatomic, copy)void (^confirmAction)(void);

@end

@implementation MKConnectAlertView
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConnectBaseView销毁");
}

- (instancetype)initWithTitleMsg:(NSString *)titleMsg
                    cancelAction:(void (^)(void))cancelAction
                   confirmAction:(void (^)(void))confirmAction{
    self = [self init];
    self.titleLabel.text = titleMsg;
    self.cancelAction = cancelAction;
    self.confirmAction = confirmAction;
    return self;
}

- (instancetype)initWithTitleMsg:(NSString *)titleMsg
              confirmButtonTitle:(NSString *)confirmTitle
               cancelButtonTitle:(NSString *)cancelTitle
                    cancelAction:(void (^)(void))cancelAction
                   confirmAction:(void (^)(void))confirmAction{
    self = [self initWithTitleMsg:titleMsg cancelAction:cancelAction confirmAction:confirmAction];
    [self.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setLayerProperty];
        [self addSubview:self.titleLabel];
        [self addSubview:self.horizontalLine];
        [self addSubview:self.verticalLine];
        [self addSubview:self.cancelButton];
        [self addSubview:self.confirmButton];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize titleSize = [NSString sizeWithText:self.titleLabel.text
                                      andFont:self.titleLabel.font
                                   andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f, MAXFLOAT)];
//    [self.titleLabel setFrame:CGRectMake(15.f, 20.f, self.frame.size.width - 2 * 15.f, titleSize.height)];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(titleSize.height);
    }];
//    [self.horizontalLine setFrame:CGRectMake(0, self.frame.size.height - 45.f - 0.5f, self.frame.size.width, 0.5f)];
    [self.horizontalLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-45.f);
        make.height.mas_equalTo(0.5f);
    }];
//    [self.verticalLine setFrame:CGRectMake(self.frame.size.width / 2 - 0.5f, self.frame.size.height - 45.f, 0.5f, 45.f)];
    [self.verticalLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(0.5f);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
//    CGFloat buttonWidth = (self.frame.size.width - 0.5f) / 2;
//    [self.cancelButton setFrame:CGRectMake(0, self.frame.size.height - 45.f,  buttonWidth, 45.f)];
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.verticalLine.mas_left);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
//    [self.confirmButton setFrame:CGRectMake(self.frame.size.width - buttonWidth, self.frame.size.height - 45.f, buttonWidth, 45.f)];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.verticalLine.mas_right);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - event method
- (void)cancelButtonPressed{
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)confirmButtonPressed{
    if (self.confirmAction) {
        self.confirmAction();
    }
}

#pragma mark - private method
- (void)setLayerProperty{
    [self setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderColor:CUTTING_LINE_COLOR.CGColor];
    [self.layer setBorderWidth:0.5f];
    [self.layer setCornerRadius:5.f];
}

#pragma mark - setter & getter
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [MKAddDeviceCenter connectAlertTitleLabel:@""];
    }
    return _titleLabel;
}

- (UIView *)horizontalLine{
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = UIColorFromRGB(0xd9d9d9);
    }
    return _horizontalLine;
}

- (UIView *)verticalLine{
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = UIColorFromRGB(0xd9d9d9);
    }
    return _verticalLine;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton.titleLabel setFont:MKFont(18.f)];
        [_cancelButton setTitleColor:UIColorFromRGB(0x0188cc) forState:UIControlStateNormal];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTapAction:self selector:@selector(cancelButtonPressed)];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton.titleLabel setFont:MKFont(18.f)];
        [_confirmButton setTitleColor:UIColorFromRGB(0x0188cc) forState:UIControlStateNormal];
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton addTapAction:self selector:@selector(confirmButtonPressed)];
    }
    return _confirmButton;
}

@end

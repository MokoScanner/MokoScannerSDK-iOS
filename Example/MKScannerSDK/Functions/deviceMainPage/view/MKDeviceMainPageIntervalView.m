//
//  MKDeviceMainPageIntervalView.m
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceMainPageIntervalView.h"

@interface MKDeviceMainPageIntervalView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *unitLabel;

@property (nonatomic, strong)UIButton *saveButton;

@property (nonatomic, strong)UILabel *totalLabel;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKDeviceMainPageIntervalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self addSubview:self.msgLabel];
        [self addSubview:self.textField];
        [self addSubview:self.unitLabel];
        [self addSubview:self.saveButton];
        [self addSubview:self.totalLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(100.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.msgLabel.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textField.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.msgLabel.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(45.f);
        make.centerY.mas_equalTo(self.msgLabel.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
}

#pragma mark - event method
- (void)saveButtonPressed {
    if ([self.delegate respondsToSelector:@selector(saveIntervalTime:)]) {
        [self.delegate saveIntervalTime:self.textField.text];
    }
}

#pragma mark - setter & getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Scan Time";
    }
    return _msgLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.font = MKFont(14.f);
        _textField.borderStyle = UITextBorderStyleNone;
        
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.borderWidth = 0.5f;
        _textField.layer.cornerRadius = 6.f;
    }
    return _textField;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textAlignment = NSTextAlignmentLeft;
        _totalLabel.textColor = DEFAULT_TEXT_COLOR;
        _totalLabel.font = MKFont(15.f);
        _totalLabel.text = @"Total:0";
    }
    return _totalLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.textColor = DEFAULT_TEXT_COLOR;
        _unitLabel.font = MKFont(15.f);
        _unitLabel.text = @"s";
    }
    return _unitLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Save" target:self action:@selector(saveButtonPressed)];
    }
    return _saveButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

@end

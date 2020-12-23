//
//  MKFilterNormalCell.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterNormalCell.h"
#import "MKFilterNormalCellModel.h"

@interface MKFilterNormalCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKFilterNormalCell

+ (MKFilterNormalCell *)initCellWithTableView:(UITableView *)tableView {
    MKFilterNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKFilterNormalCellIdenty"];
    if (!cell) {
        cell = [[MKFilterNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKFilterNormalCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(50.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.switchButton.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.switchButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)switchButtonPressed {
    self.switchButton.selected = !self.switchButton.selected;
    UIImage *buttonImage = (self.switchButton.selected ? LOADIMAGE(@"deviceList_switchStateOnIcon", @"png") : LOADIMAGE(@"deviceList_switchStateOffIcon", @"png"));
    [self.switchButton setImage:buttonImage forState:UIControlStateNormal];
    [self.textField setHidden:!self.switchButton.selected];
    if ([self.delegate respondsToSelector:@selector(fliterSwitchStatusChanged:index:)]) {
        [self.delegate fliterSwitchStatusChanged:self.switchButton.selected index:self.dataModel.index];
    }
}

- (void)textFieldValueChanged {
    if (self.dataModel.maxLength > 0 && self.textField.text.length > self.dataModel.maxLength) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(filterContent:index:)]) {
        [self.delegate filterContent:self.textField.text index:self.dataModel.index];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKFilterNormalCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = _dataModel.msg;
    if (self.textField.superview) {
        [self.textField removeFromSuperview];
    }
    self.textField = nil;
    self.textField = [self textFieldWithPlaceholder:_dataModel.textPlaceholder
                                              value:_dataModel.textFieldValue
                                          maxLength:_dataModel.maxLength
                                               type:_dataModel.textFieldType];
    [self.contentView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(5.f);
        make.bottom.mas_equalTo(-5.f);
    }];
    self.switchButton.selected = _dataModel.isOn;
    UIImage *buttonImage = (self.switchButton.selected ? LOADIMAGE(@"deviceList_switchStateOnIcon", @"png") : LOADIMAGE(@"deviceList_switchStateOffIcon", @"png"));
    [self.switchButton setImage:buttonImage forState:UIControlStateNormal];
    [self.textField setHidden:!_dataModel.isOn];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    return _msgLabel;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:LOADIMAGE(@"deviceList_switchStateOffIcon", @"png") forState:UIControlStateNormal];
        [_switchButton addTapAction:self selector:@selector(switchButtonPressed)];
    }
    return _switchButton;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
                                    value:(NSString *)value
                                maxLength:(NSInteger)maxLength
                                     type:(mk_CustomTextFieldType)type {
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:type];
    textField.backgroundColor = COLOR_WHITE_MACROS;
    textField.maxLength = maxLength;
    textField.placeholder = placeholder;
    textField.text = value;
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 0.5f;
    textField.layer.borderColor = RGBCOLOR(162, 162, 162).CGColor;
    textField.layer.cornerRadius = 6.f;
    
    [textField addTarget:self
                  action:@selector(textFieldValueChanged)
        forControlEvents:UIControlEventEditingChanged];
    return textField;
}

@end

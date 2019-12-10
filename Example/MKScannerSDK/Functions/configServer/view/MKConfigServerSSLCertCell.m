//
//  MKConfigServerSSLCertCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKConfigServerSSLCertCell.h"
#import "MKConfigServerSSLCertModel.h"

static NSString *const MKConfigServerSSLCertCellIdenty = @"MKConfigServerSSLCertCellIdenty";

@interface MKConfigServerSSLCertCell ()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UIButton *selectedButton;

@end

@implementation MKConfigServerSSLCertCell

+ (MKConfigServerSSLCertCell *)initCellWithTableView:(UITableView *)tableView {
    MKConfigServerSSLCertCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerSSLCertCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerSSLCertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerSSLCertCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize msgLabelSize = [NSString sizeWithText:self.msgLabel.text
                                         andFont:self.msgLabel.font
                                      andMaxSize:CGSizeMake(MAXFLOAT, MKFont(15.f).lineHeight)];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(msgLabelSize.width);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(6.f);
        make.right.mas_equalTo(self.selectedButton.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.selectedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(45.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - event method
- (void)selectedButtonPressed {
    if ([self.delegate respondsToSelector:@selector(sslCertCellSelectedButtonPressed:)]) {
        [self.delegate sslCertCellSelectedButtonPressed:self.dataModel.index];
    }
}

- (void)textFieldValueChanged {
    if ([self.delegate respondsToSelector:@selector(sslCertCellTextFieldValueChanged:index:)]) {
        [self.delegate sslCertCellTextFieldValueChanged:self.textField.text index:self.dataModel.index];
    }
}

#pragma mark - public method
- (void)setDataModel:(MKConfigServerSSLCertModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = dataModel.msgTitle;
    self.textField.text = dataModel.certName;
    [self setNeedsLayout];
}


#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
    }
    return _msgLabel;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [MKCommonlyUIHelper configServerTextField];
        _textField.delegate = self;
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setImage:LOADIMAGE(@"mokoLife_config_certAddIcon", @"png") forState:UIControlStateNormal];
        [_selectedButton addTapAction:self selector:@selector(selectedButtonPressed)];
    }
    return _selectedButton;
}

@end

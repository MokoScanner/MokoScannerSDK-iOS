//
//  MKUpdateFirmwareCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKUpdateFirmwareCell.h"

static CGFloat const msgLabelWidth = 100.f;
static CGFloat const textFieldHeight = 45.f;

static NSString *const MKUpdateFirmwareCellIdenty = @"MKUpdateFirmwareCellIdenty";

@interface MKUpdateFirmwareCell()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKUpdateFirmwareCell

+ (MKUpdateFirmwareCell *)initCellWithTable:(UITableView *)tableView{
    MKUpdateFirmwareCell *cell = [tableView dequeueReusableCellWithIdentifier:MKUpdateFirmwareCellIdenty];
    if (!cell) {
        cell = [[MKUpdateFirmwareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKUpdateFirmwareCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(6.f);
        make.right.mas_equalTo(-21.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(textFieldHeight);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKUpdateCellProtocol
- (NSString *)currentValue{
    return [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - public method
- (void)setMsg:(NSString *)msg{
    _msg = nil;
    _msg = msg;
    self.textField.text = @"";
    if (!ValidStr(_msg)) {
        return;
    }
    self.msgLabel.text = _msg;
}

- (void)hiddenKeyBoard {
    [self.textField resignFirstResponder];
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
    }
    return _textField;
}

@end

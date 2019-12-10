//
//  MKConfigServerHostCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerHostCell.h"

//static CGFloat const starIconWidth = 6.f;
//static CGFloat const starIconHeight = 6.f;
static CGFloat const msgLabelWidth = 40.f;
static CGFloat const textFieldHeight = 45.f;

static NSString *const MKConfigServerHostCellIdenty = @"MKConfigServerHostCellIdenty";

@interface MKConfigServerHostCell()<UITextFieldDelegate>

@property (nonatomic, strong)UIImageView *starIcon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKConfigServerHostCell

+ (MKConfigServerHostCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerHostCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerHostCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerHostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerHostCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
//        [self.contentView addSubview:self.starIcon];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
//    [self.starIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.f);
//        make.width.mas_equalTo(starIconWidth);
//        make.centerY.mas_equalTo(self.contentView.mas_centerY);
//        make.height.mas_equalTo(starIconHeight);
//    }];
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

#pragma mark - MKConfigServerCellProtocol
/**
 获取当前cell显示的数值
 
 @return @{
 @"row":@(row),
 @"xx":@"xx"
 @"xx":@"xx"
 }
 */
- (NSDictionary *)configServerCellValue{
    NSString *host = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return @{@"host":host};
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    self.textField.text = @"";
}

/**
 设置参数
 
 @param params 参数
 */
- (void)setParams:(id)params{
    if (!ValidStr(params)) {
        return;
    }
    self.textField.text = params;
}

/**
 隐藏键盘
 */
- (void)hiddenKeyBoard{
    [self.textField resignFirstResponder];
}

#pragma mark - setter & getter
- (UIImageView *)starIcon{
    if (!_starIcon) {
        _starIcon = [[UIImageView alloc] init];
        _starIcon.image = LOADIMAGE(@"configServer_starIcon", @"png");
    }
    return _starIcon;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _msgLabel.text = @"Host";
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

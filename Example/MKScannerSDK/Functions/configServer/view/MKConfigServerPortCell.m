//
//  MKConfigServerPortCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerPortCell.h"

//static CGFloat const starIconWidth = 6.f;
//static CGFloat const starIconHeight = 6.f;
static CGFloat const portLabelWidth = 40.f;
static CGFloat const textFieldHeight = 45.f;

static NSString *const MKConfigServerPortCellIdenty = @"MKConfigServerPortCellIdenty";

@interface MKConfigServerPortCell()<UITextFieldDelegate>

@property (nonatomic, strong)UIImageView *starIcon;

@property (nonatomic, strong)UILabel *portLabel;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *cleanSessionLabel;

@property (nonatomic, strong)UISwitch *switchView;

@end

@implementation MKConfigServerPortCell

+ (MKConfigServerPortCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerPortCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerPortCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerPortCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerPortCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
//        [self.contentView addSubview:self.starIcon];
        [self.contentView addSubview:self.portLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.cleanSessionLabel];
        [self.contentView addSubview:self.switchView];
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
    [self.portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(portLabelWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.portLabel.mas_right).mas_offset(6.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-8);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.cleanSessionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(8.f);
        make.right.mas_equalTo(self.switchView.mas_left).mas_offset(-6.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-21.f);
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
    NSString *port = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return @{
             @"port":port,
             @"cleanSession":@(self.switchView.on)
             };
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    self.textField.text = @"";
    self.switchView.on = YES;
}

/**
 设置参数
 
 @param params 参数
 */
- (void)setParams:(id)params{
    if (!ValidDict(params)) {
        return;
    }
    if (ValidStr(params[@"port"])) {
        self.textField.text = params[@"port"];
    }
    self.switchView.on = [params[@"clean"] boolValue];
}

/**
 隐藏键盘a
 */
- (void)hiddenKeyBoard{
    [self.textField resignFirstResponder];
}

#pragma mark - event method
- (void)switchValueChanged{
    
}

#pragma mark - setter & getter
- (UIImageView *)starIcon{
    if (!_starIcon) {
        _starIcon = [[UIImageView alloc] init];
        _starIcon.image = LOADIMAGE(@"configServer_starIcon", @"png");
    }
    return _starIcon;
}

- (UILabel *)portLabel{
    if (!_portLabel) {
        _portLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _portLabel.text = @"Port";
    }
    return _portLabel;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [MKCommonlyUIHelper configServerTextField];
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.maxLength = 5;
        _textField.delegate = self;
    }
    return _textField;
}

- (UILabel *)cleanSessionLabel{
    if (!_cleanSessionLabel) {
        _cleanSessionLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _cleanSessionLabel.text = @"Clean Session";
    }
    return _cleanSessionLabel;
}

- (UISwitch *)switchView{
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
//        _switchView.on = YES;
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

@end

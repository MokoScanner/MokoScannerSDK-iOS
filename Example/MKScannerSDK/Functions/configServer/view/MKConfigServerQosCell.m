//
//  MKConfigServerQosCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerQosCell.h"

static CGFloat const triangleIconWidth = 9.f;
static CGFloat const triangleIconHeight = 8.f;
//static CGFloat const starIconWidth = 6.f;
//static CGFloat const starIconHeight = 6.f;
static CGFloat const valueViewHeight = 45.f;

static NSString *const MKConfigServerQosCellIdenty = @"MKConfigServerQosCellIdenty";

@interface MKConfigServerQosCell()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *qosLabel;

@property (nonatomic, strong)UILabel *qosValueLabel;

@property (nonatomic, strong)UIView *qosValueView;

@property (nonatomic, strong)UIImageView *triangleIcon;

@property (nonatomic, strong)UILabel *aliveLabel;

@property (nonatomic, strong)UITextField *aliveTextField;

@property (nonatomic, strong)UIView *aliveValueView;

@property (nonatomic, strong)UIImageView *starIcon;

@end

@implementation MKConfigServerQosCell

+ (MKConfigServerQosCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerQosCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerQosCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerQosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerQosCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.qosLabel];
        [self.contentView addSubview:self.qosValueView];
        [self.qosValueView addSubview:self.triangleIcon];
        [self.qosValueView addSubview:self.qosValueLabel];
//        [self.contentView addSubview:self.starIcon];
        [self.contentView addSubview:self.aliveLabel];
        [self.contentView addSubview:self.aliveValueView];
        [self.aliveValueView addSubview:self.aliveTextField];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.qosLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.qosValueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qosLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(valueViewHeight);
    }];
    [self.qosValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(self.triangleIcon.mas_left).mas_offset(-2.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.triangleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10.f);
        make.width.mas_equalTo(triangleIconWidth);
        make.centerY.mas_equalTo(_qosValueView.mas_centerY);
        make.height.mas_equalTo(triangleIconHeight);
    }];
//    [self.starIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
//        make.width.mas_equalTo(starIconWidth);
//        make.centerY.mas_equalTo(self.contentView.mas_centerY);
//        make.height.mas_equalTo(starIconHeight);
//    }];
    [self.aliveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
        make.width.mas_equalTo(85.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.aliveValueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.aliveLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-21.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(valueViewHeight);
    }];
    [self.aliveTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(valueViewHeight - 1.f);
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
    NSString *keepAlive = [self.aliveTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return @{
             @"qos":self.qosValueLabel.text,
             @"keepAlive":keepAlive
             };
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    self.qosValueLabel.text = @"1";
    self.aliveTextField.text = @"60";
}

/**
 设置参数
 
 @param params 参数
 */
- (void)setParams:(id)params{
    if (!ValidDict(params)) {
        return;
    }
    if (ValidStr(params[@"qos"])) {
        self.qosValueLabel.text = params[@"qos"];
    }
    if (ValidStr(params[@"keepAlive"])) {
        self.aliveTextField.text = params[@"keepAlive"];
    }
}

/**
 隐藏键盘
 */
- (void)hiddenKeyBoard{
    [self.aliveTextField resignFirstResponder];
}

#pragma mark - event method
- (void)qosValueViewPressed{
    [[NSNotificationCenter defaultCenter] postNotificationName:configCellNeedHiddenKeyboardNotification object:nil];
    WS(weakSelf);
    [MKConfigServerAdopter showQosPickViewWithCurrentData:self.qosValueLabel.text
                                             confirmBlock:^(NSString *data, NSInteger selectedRow) {
        if (ValidStr(data)) {
            weakSelf.qosValueLabel.text = data;
        }
    }];
}

#pragma mark - setter & getter
- (UILabel *)qosLabel{
    if (!_qosLabel) {
        _qosLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _qosLabel.text = @"Qos";
    }
    return _qosLabel;
}

- (UILabel *)qosValueLabel{
    if (!_qosValueLabel) {
        _qosValueLabel = [self valueLabel];
        _qosValueLabel.text = @"1";
    }
    return _qosValueLabel;
}

- (UIImageView *)triangleIcon{
    if (!_triangleIcon) {
        _triangleIcon = [[UIImageView alloc] init];
        _triangleIcon.image = LOADIMAGE(@"configServer_triangleIcon", @"png");
    }
    return _triangleIcon;
}

- (UIView *)qosValueView{
    if (!_qosValueView) {
        _qosValueView = [[UIView alloc] init];
        _qosValueView.backgroundColor = COLOR_WHITE_MACROS;
        _qosValueView.layer.masksToBounds = YES;
        _qosValueView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _qosValueView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _qosValueView.layer.cornerRadius = 5.f;
        [_qosValueView addTapAction:self selector:@selector(qosValueViewPressed)];
    }
    return _qosValueView;
}

- (UILabel *)aliveLabel{
    if (!_aliveLabel) {
        _aliveLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _aliveLabel.text = @"Keep Alive";
    }
    return _aliveLabel;
}

- (UITextField *)aliveTextField{
    if (!_aliveTextField) {
        _aliveTextField = [[UITextField alloc] init];
        _aliveTextField.backgroundColor = COLOR_WHITE_MACROS;
        _aliveTextField.borderStyle = UITextBorderStyleNone;
        _aliveTextField.textColor = DEFAULT_TEXT_COLOR;
        _aliveTextField.textAlignment = NSTextAlignmentLeft;
        _aliveTextField.font = MKFont(15.f);
        _aliveTextField.keyboardType = UIKeyboardTypePhonePad;
        _aliveTextField.delegate = self;
        _aliveTextField.text = @"60";
    }
    return _aliveTextField;
}

- (UIView *)aliveValueView{
    if (!_aliveValueView) {
        _aliveValueView = [[UIView alloc] init];
        _aliveValueView.backgroundColor = COLOR_WHITE_MACROS;
        _aliveValueView.layer.masksToBounds = YES;
        _aliveValueView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _aliveValueView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _aliveValueView.layer.cornerRadius = 5.f;
    }
    return _aliveValueView;
}

- (UIImageView *)starIcon{
    if (!_starIcon) {
        _starIcon = [[UIImageView alloc] init];
        _starIcon.image = LOADIMAGE(@"configServer_starIcon", @"png");
    }
    return _starIcon;
}

- (UILabel *)valueLabel{
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.textAlignment = NSTextAlignmentLeft;
    valueLabel.font = MKFont(15.f);
    valueLabel.textColor = DEFAULT_TEXT_COLOR;
    return valueLabel;
}

@end

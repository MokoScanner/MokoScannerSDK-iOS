//
/*
 参数校验规则:
 1、dataType 参考https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile/
 2、minTextField如果填写为0，maxTextField可以不填写任何数字,也可以填写为0.minTextField如果大于0，maxTextField必须不小于minTextField，并且2者都在1~29之间
 3、rawDataField
 如果minTextField为0，则rawDataField必须填写最大长度不超过58个字符的偶数个字符，该字符必须为16进制字符，
 如果minTextField填写的数字跟maxTextField填写的一样且不为0，则rawDataField填写的字符长度应该为(maxTextField - minTextField + 1) * 2，
 如果minTextField填写的数字小于maxTextField填写的数字，则rawDataField填写的字符长度应该为(maxTextField - minTextField + 1) * 2;
 */
//

#import "MKFilterRawDataCell.h"
#import "MKFilterRawDataCellModel.h"

@interface MKFilterRawDataCell ()

@property (nonatomic, strong)UITextField *typeTextField;

@property (nonatomic, strong)UITextField *minTextField;

@property (nonatomic, strong)UITextField *maxTextField;

@property (nonatomic, strong)UILabel *characterLabel;

@property (nonatomic, strong)UILabel *unitLabel;

@property (nonatomic, strong)UITextField *rawDataField;

@end

@implementation MKFilterRawDataCell

+ (MKFilterRawDataCell *)initCellWithTableView:(UITableView *)tableView {
    MKFilterRawDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKFilterRawDataCellIdenty"];
    if (!cell) {
        cell = [[MKFilterRawDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKFilterRawDataCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.typeTextField];
        [self.contentView addSubview:self.minTextField];
        [self.contentView addSubview:self.maxTextField];
        [self.contentView addSubview:self.characterLabel];
        [self.contentView addSubview:self.unitLabel];
        [self.contentView addSubview:self.rawDataField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.typeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(70.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.minTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.typeTextField.mas_right).mas_offset(20.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.typeTextField.mas_centerY);
        make.height.mas_equalTo(self.typeTextField.mas_height);
    }];
    [self.characterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.minTextField.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(20.f);
        make.centerY.mas_equalTo(self.typeTextField.mas_centerY);
        make.height.mas_equalTo(self.typeTextField.mas_height);
    }];
    [self.maxTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.characterLabel.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.typeTextField.mas_centerY);
        make.height.mas_equalTo(self.typeTextField.mas_height);
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.maxTextField.mas_right).mas_offset(3.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.typeTextField.mas_centerY);
        make.height.mas_equalTo(self.typeTextField.mas_height);
    }];
    [self.rawDataField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.typeTextField.mas_bottom).mas_offset(15.f);
        make.bottom.mas_equalTo(-5.f);
    }];
}

#pragma mark -
- (void)textFieldValueChanged:(UITextField *)textField {
    mk_filterRawDataCellTextType textType = mk_filterRawDataCellTextTypeDataType;
    NSInteger maxLen = 2;
    if (textField == self.minTextField) {
        textType = mk_filterRawDataCellTextTypeMinIndex;
    }else if (textField == self.maxTextField) {
        textType = mk_filterRawDataCellTextTypeMaxIndex;
    }else if (textField == self.rawDataField) {
        textType = mk_filterRawDataCellTextTypeRawDataType;
        maxLen = 58;
    }
    if (textField.text.length > maxLen) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(rawFilterDataChanged:index:textValue:)]) {
        [self.delegate rawFilterDataChanged:textType index:self.indexPath.row textValue:textField.text];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKFilterRawDataCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.typeTextField.text = SafeStr(_dataModel.dataType);
    self.minTextField.text = SafeStr(_dataModel.minIndex);
    self.maxTextField.text = SafeStr(_dataModel.maxIndex);
    self.rawDataField.text = SafeStr(_dataModel.rawData);
}

#pragma mark -
- (UITextField *)typeTextField {
    if (!_typeTextField) {
        _typeTextField = [self loadTextWithTextType:hexCharOnly placeHolder:@"Data Type" maxLen:2];
    }
    return _typeTextField;
}

- (UITextField *)minTextField {
    if (!_minTextField) {
        _minTextField = [self loadTextWithTextType:realNumberOnly placeHolder:@"" maxLen:2];
    }
    return _minTextField;
}

- (UITextField *)maxTextField {
    if (!_maxTextField) {
        _maxTextField = [self loadTextWithTextType:realNumberOnly placeHolder:@"" maxLen:2];
    }
    return _maxTextField;
}

- (UILabel *)characterLabel {
    if (!_characterLabel) {
        _characterLabel = [[UILabel alloc] init];
        _characterLabel.textAlignment = NSTextAlignmentCenter;
        _characterLabel.textColor = DEFAULT_TEXT_COLOR;
        _characterLabel.font = MKFont(20.f);
        _characterLabel.text = @"~";
    }
    return _characterLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.textColor = DEFAULT_TEXT_COLOR;
        _unitLabel.font = MKFont(13.f);
        _unitLabel.text = @"Byte";
    }
    return _unitLabel;
}

- (UITextField *)rawDataField {
    if (!_rawDataField) {
        _rawDataField = [self loadTextWithTextType:hexCharOnly placeHolder:@"Raw data field" maxLen:58];
    }
    return _rawDataField;
}

- (UITextField *)loadTextWithTextType:(mk_CustomTextFieldType)fieldType
                          placeHolder:(NSString *)placeHolder
                               maxLen:(NSInteger)maxLen {
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:fieldType];
    textField.backgroundColor = COLOR_WHITE_MACROS;
    textField.maxLength = maxLen;
    textField.placeholder = placeHolder;
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 0.5f;
    textField.layer.borderColor = RGBCOLOR(162, 162, 162).CGColor;
    textField.layer.cornerRadius = 6.f;
    
    [textField addTarget:self
                  action:@selector(textFieldValueChanged:)
        forControlEvents:UIControlEventEditingChanged];
    return textField;
}

@end

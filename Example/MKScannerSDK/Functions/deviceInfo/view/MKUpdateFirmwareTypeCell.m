//
//  MKUpdateFirmwareTypeCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/8/8.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKUpdateFirmwareTypeCell.h"
#import "MKConfigServerPickView.h"

@interface MKUpdateFirmwareTypeCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *typeButton;

@end

@implementation MKUpdateFirmwareTypeCell

+ (MKUpdateFirmwareTypeCell *)initCellWithTableView:(UITableView *)tableView {
    MKUpdateFirmwareTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKUpdateFirmwareTypeCellIdenty"];
    if (!cell) {
        cell = [[MKUpdateFirmwareTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKUpdateFirmwareTypeCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.typeButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(100.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(6.f);
        make.right.mas_equalTo(-25.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(40.f);
    }];
}

#pragma mark - event method
- (void)typeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(needHiddenKeyBoard)]) {
        [self.delegate needHiddenKeyBoard];
    }
    MKConfigServerPickView *pickView = [[MKConfigServerPickView alloc] init];
    NSArray *dataList = @[@"Firmware",@"CA certification",@"Client certification",@"Client key"];
    [pickView showConfigServerPickViewWithDataList:dataList currentData:self.typeButton.titleLabel.text block:^(NSString *data, NSInteger selectedRow) {
        [self.typeButton setTitle:dataList[selectedRow] forState:UIControlStateNormal];
    }];
}

#pragma mark - public method
- (updateFirmwareCellType)currentFileType {
    if ([self.typeButton.titleLabel.text isEqualToString:@"Firmware"]) {
        return update_firmware;
    }
    if ([self.typeButton.titleLabel.text isEqualToString:@"CA certification"]) {
        return update_caCertification;
    }
    if ([self.typeButton.titleLabel.text isEqualToString:@"Client certification"]) {
        return update_clientCertification;
    }
    return update_clientKey;
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _msgLabel.text = @"Type";
    }
    return _msgLabel;
}

- (UIButton *)typeButton {
    if (!_typeButton) {
        _typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeButton.backgroundColor = UIColorFromRGB(0x0188cc);
        [_typeButton setTitle:@"Firmware" forState:UIControlStateNormal];
        [_typeButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_typeButton.titleLabel setFont:MKFont(15.f)];
        [_typeButton.layer setMasksToBounds:YES];
        [_typeButton.layer setCornerRadius:5.f];
        [_typeButton addTapAction:self selector:@selector(typeButtonPressed)];
    }
    return _typeButton;
}

@end

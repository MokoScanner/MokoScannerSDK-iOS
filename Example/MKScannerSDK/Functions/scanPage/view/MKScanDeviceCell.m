//
//  MKScanDeviceCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKScanDeviceCell.h"
#import "MKScanDeviceModel.h"

static NSString *const MKScanDeviceCellIdenty = @"MKScanDeviceCellIdenty";

@interface MKScanDeviceCell()

@property (nonatomic, strong)UILabel *leftMsgLabel;

@property (nonatomic, strong)UILabel *rightMsgLabel;

@end

@implementation MKScanDeviceCell

+ (MKScanDeviceCell *)initCellWithTableView:(UITableView *)tableView{
    MKScanDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:MKScanDeviceCellIdenty];
    if (!cell) {
        cell = [[MKScanDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKScanDeviceCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = COLOR_WHITE_MACROS;
        [self.contentView addSubview:self.leftMsgLabel];
        [self.contentView addSubview:self.rightMsgLabel];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.leftMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.rightMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark - setter & getter
- (void)setDataModel:(MKScanDeviceModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.deviceName)) {
        self.leftMsgLabel.text = _dataModel.deviceName;
    }else {
        self.leftMsgLabel.text = @"N/A";
    }
    if (ValidStr(_dataModel.rssi)) {
        self.rightMsgLabel.text = _dataModel.rssi;
    }
}

#pragma mark - setter & getter
- (UILabel *)leftMsgLabel{
    if (!_leftMsgLabel) {
        _leftMsgLabel = [[UILabel alloc] init];
        _leftMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _leftMsgLabel.textAlignment = NSTextAlignmentLeft;
        _leftMsgLabel.font = MKFont(18.f);
    }
    return _leftMsgLabel;
}

- (UILabel *)rightMsgLabel{
    if (!_rightMsgLabel) {
        _rightMsgLabel = [[UILabel alloc] init];
        _rightMsgLabel.textColor = UIColorFromRGB(0x808080);
        _rightMsgLabel.textAlignment = NSTextAlignmentRight;
        _rightMsgLabel.font = MKFont(13.f);
    }
    return _rightMsgLabel;
}

@end

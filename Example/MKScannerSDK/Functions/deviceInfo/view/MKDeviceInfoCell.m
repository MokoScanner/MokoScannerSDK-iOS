//
//  MKDeviceInfoCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInfoCell.h"
#import "MKDeviceInfoModel.h"

static NSString *const MKDeviceInfoCellIdenty = @"MKDeviceInfoCellIdenty";

static CGFloat const rightIconWidth = 8.f;
static CGFloat const rightIconHeight = 15.f;

@interface MKDeviceInfoCell()

@property (nonatomic, strong)UILabel *leftMsgLabel;

@property (nonatomic, strong)UILabel *rightMsgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKDeviceInfoCell

+ (MKDeviceInfoCell *)initCellWithTableView:(UITableView *)tableView{
    MKDeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:MKDeviceInfoCellIdenty];
    if (!cell) {
        cell = [[MKDeviceInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKDeviceInfoCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftMsgLabel];
        [self.contentView addSubview:self.rightMsgLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.leftMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rightMsgLabel.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(130.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(rightIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(rightIconHeight);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKDeviceInfoModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.leftMsgLabel.text = (ValidStr(_dataModel.leftMsg) ? _dataModel.leftMsg : @"");
    self.rightMsgLabel.text = (ValidStr(_dataModel.rightMsg) ? _dataModel.rightMsg : @"");
}

#pragma mark - setter & getter
- (UILabel *)leftMsgLabel{
    if (!_leftMsgLabel) {
        _leftMsgLabel = [[UILabel alloc] init];
        _leftMsgLabel.textAlignment = NSTextAlignmentLeft;
        _leftMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _leftMsgLabel.font = MKFont(15.f);
    }
    return _leftMsgLabel;
}

- (UILabel *)rightMsgLabel{
    if (!_rightMsgLabel) {
        _rightMsgLabel = [[UILabel alloc] init];
        _rightMsgLabel.textAlignment = NSTextAlignmentRight;
        _rightMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _rightMsgLabel.font = MKFont(13.f);
    }
    return _rightMsgLabel;
}

- (UIImageView *)rightIcon{
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADIMAGE(@"rightNextIcon", @"png");
    }
    return _rightIcon;
}

@end

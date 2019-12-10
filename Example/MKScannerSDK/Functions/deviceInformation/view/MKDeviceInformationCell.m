//
//  MKDeviceInformationCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceInformationCell.h"
#import "MKDeviceInformationModel.h"

static NSString *const MKDeviceInformationCellIdenty = @"MKDeviceInformationCellIdenty";

@interface MKDeviceInformationCell()

@property (nonatomic, strong)UILabel *leftMsgLabel;

@property (nonatomic, strong)UILabel *rightMsgLabel;

@end

@implementation MKDeviceInformationCell

+ (MKDeviceInformationCell *)initCellWithTableView:(UITableView *)tableView{
    MKDeviceInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:MKDeviceInformationCellIdenty];
    if (!cell) {
        cell = [[MKDeviceInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKDeviceInformationCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftMsgLabel];
        [self.contentView addSubview:self.rightMsgLabel];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize leftMsgSize = [NSString sizeWithText:self.leftMsgLabel.text
                                        andFont:self.leftMsgLabel.font
                                     andMaxSize:CGSizeMake((kScreenWidth / 2 - 20.f), MAXFLOAT)];
    [self.leftMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MAX(MKFont(18.f).lineHeight, leftMsgSize.height));
    }];
    CGSize rightMsgSize = [NSString sizeWithText:self.rightMsgLabel.text
                                         andFont:self.rightMsgLabel.font
                                      andMaxSize:CGSizeMake((kScreenWidth / 2 - 20.f), MAXFLOAT)];
    [self.rightMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MAX(MKFont(13.f).lineHeight, rightMsgSize.height));
    }];
}

#pragma mark -
+ (CGFloat)fetchCurrentCellHeight:(MKDeviceInformationModel *)dataModel {
    CGSize rightMsgSize = [NSString sizeWithText:dataModel.rightMsg
                                         andFont:MKFont(13.f)
                                      andMaxSize:CGSizeMake((kScreenWidth / 2 - 20.f), MAXFLOAT)];
    CGSize leftMsgSize = [NSString sizeWithText:dataModel.leftMsg
                                        andFont:MKFont(18.f)
                                     andMaxSize:CGSizeMake((kScreenWidth / 2 - 20.f), MAXFLOAT)];
    CGFloat cellHeight1 = MAX(rightMsgSize.height, MKFont(13.f).lineHeight);
    CGFloat cellHeight2 = MAX(leftMsgSize.height, MKFont(18.f).lineHeight);
    CGFloat resultHeight = MAX(cellHeight1, cellHeight2);
    return MAX(resultHeight, 44.f);
}

#pragma mark - setter & getter
- (void)setDataModel:(MKDeviceInformationModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.leftMsg)) {
        self.leftMsgLabel.text = _dataModel.leftMsg;
    }else {
        self.leftMsgLabel.text = @"";
    }
    if (ValidStr(_dataModel.rightMsg)) {
        self.rightMsgLabel.text = _dataModel.rightMsg;
    }else {
        self.rightMsgLabel.text = @"";
    }
    [self setNeedsLayout];
}

#pragma mark - setter & getter
- (UILabel *)leftMsgLabel{
    if (!_leftMsgLabel) {
        _leftMsgLabel = [[UILabel alloc] init];
        _leftMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _leftMsgLabel.textAlignment = NSTextAlignmentLeft;
        _leftMsgLabel.font = MKFont(18.f);
        _leftMsgLabel.numberOfLines = 0;
    }
    return _leftMsgLabel;
}

- (UILabel *)rightMsgLabel{
    if (!_rightMsgLabel) {
        _rightMsgLabel = [[UILabel alloc] init];
        _rightMsgLabel.textColor = UIColorFromRGB(0x808080);
        _rightMsgLabel.textAlignment = NSTextAlignmentRight;
        _rightMsgLabel.font = MKFont(13.f);
        _rightMsgLabel.numberOfLines = 0;
    }
    return _rightMsgLabel;
}

@end

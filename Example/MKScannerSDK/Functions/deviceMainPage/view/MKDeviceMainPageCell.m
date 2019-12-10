//
//  MKDeviceMainPageCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/19.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceMainPageCell.h"

static NSString *const MKDeviceMainPageCellIdenty = @"MKDeviceMainPageCellIdenty";

@interface MKDeviceMainPageCell ()

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UILabel *macLabel;

@property (nonatomic, strong)UILabel *rssiLabel;

@property (nonatomic, strong)UILabel *rawDataLabel;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKDeviceMainPageCell

+ (MKDeviceMainPageCell *)initCellWithTableView:(UITableView *)tableView {
    MKDeviceMainPageCell *cell = [tableView dequeueReusableCellWithIdentifier:MKDeviceMainPageCellIdenty];
    if (!cell) {
        cell = [[MKDeviceMainPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKDeviceMainPageCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = COLOR_WHITE_MACROS;
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.macLabel];
        [self.contentView addSubview:self.rssiLabel];
        [self.contentView addSubview:self.rawDataLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize nameSize = [NSString sizeWithText:self.nameLabel.text
                                     andFont:MKFont(14.f)
                                  andMaxSize:CGSizeMake(kScreenWidth - 30.f, MAXFLOAT)];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(nameSize.height);
    }];
    [self.macLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.rssiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.macLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    CGSize rawDataSize = [NSString sizeWithText:self.rawDataLabel.text
                                        andFont:MKFont(14.f)
                                     andMaxSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT)];
    [self.rawDataLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.rssiLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(rawDataSize.height);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
}

#pragma mark -

+ (CGFloat)fetchCellHeight:(NSDictionary *)dataDic {
    NSString *tempDeviceName = @"Name: N/A";
    if (ValidStr(dataDic[@"deviceName"])) {
        tempDeviceName = [@"Name: " stringByAppendingString:dataDic[@"deviceName"]];
    }
    CGSize nameSize = [NSString sizeWithText:tempDeviceName
                                     andFont:MKFont(14.f)
                                  andMaxSize:CGSizeMake(kScreenWidth - 30.f, MAXFLOAT)];
    CGFloat nameHeight = MAX(nameSize.height, MKFont(14.f).lineHeight);
    NSString *tempRawData = @"Raw Data: N/A";
    if (ValidStr(dataDic[@"rawData"])) {
        tempRawData = [@"Raw Data: " stringByAppendingString:dataDic[@"rawData"]];
    }
    CGSize rawDataSize = [NSString sizeWithText:tempRawData
                                        andFont:MKFont(14.f)
                                     andMaxSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT)];
    CGFloat rawDataHeight = MAX(rawDataSize.height, MKFont(14.f).lineHeight);
    return (75.f + nameHeight + rawDataHeight);
}

- (void)setDataModel:(NSDictionary *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(dataModel[@"deviceName"])) {
        self.nameLabel.text = [@"Name: " stringByAppendingString:dataModel[@"deviceName"]];
    }else {
        self.nameLabel.text = @"Name: N/A";
    }
    if (ValidStr(dataModel[@"macAddress"])) {
        self.macLabel.text = [@"MAC: " stringByAppendingString:dataModel[@"macAddress"]];
    }else {
        self.macLabel.text = @"MAC: N/A";
    }
    if (ValidNum(dataModel[@"rssi"])) {
        NSString *tempRssi = [NSString stringWithFormat:@"%ld",(long)[dataModel[@"rssi"] integerValue]];
        self.rssiLabel.text = [NSString stringWithFormat:@"%@%@%@",@"RSSI: ",tempRssi,@"dBm"];
    }else {
        self.rssiLabel.text = @"RSSI: N/A";
    }
    if (ValidStr(dataModel[@"rawData"])) {
        self.rawDataLabel.text = [@"Raw Data: " stringByAppendingString:dataModel[@"rawData"]];
    }else {
        self.rawDataLabel.text = @"Raw Data: N/A";
    }
    [self setNeedsLayout];
}

#pragma mark - setter & getter

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [self createMsgLabel];
        _nameLabel.text = @"Name:";
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UILabel *)macLabel {
    if (!_macLabel) {
        _macLabel = [self createMsgLabel];
        _macLabel.text = @"MAC:";
    }
    return _macLabel;
}

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [self createMsgLabel];
        _rssiLabel.text = @"RSSI:";
    }
    return _rssiLabel;
}

- (UILabel *)rawDataLabel {
    if (!_rawDataLabel) {
        _rawDataLabel = [self createMsgLabel];
        _rawDataLabel.text = @"Raw Data:";
        _rawDataLabel.numberOfLines = 0;
    }
    return _rawDataLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

- (UILabel *)createMsgLabel {
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textColor = UIColorFromRGB(0x333333);
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.font = MKFont(14.f);
    return msgLabel;
}

@end

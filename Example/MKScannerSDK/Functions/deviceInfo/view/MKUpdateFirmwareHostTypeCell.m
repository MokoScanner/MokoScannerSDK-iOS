//
//  MKUpdateFirmwareHostTypeCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKUpdateFirmwareHostTypeCell.h"

static CGFloat const iconWidth = 13.f;
static CGFloat const iconHeight = 13.f;
static CGFloat const labelWidth = 40.f;
static CGFloat const buttonViewWidth = 65.f;
static CGFloat const buttonViewHeight = 30.f;

static NSString *const MKUpdateFirmwareHostTypeCellIdenty = @"MKUpdateFirmwareHostTypeCellIdenty";

@interface MKUpdateFirmwareHostTypeCell()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIView *ipView;

@property (nonatomic, strong)UIImageView *ipIcon;

@property (nonatomic, strong)UIView *urlView;

@property (nonatomic, strong)UIImageView *urlIcon;

@property (nonatomic, assign)NSInteger modeNumber;

@end

@implementation MKUpdateFirmwareHostTypeCell

+ (MKUpdateFirmwareHostTypeCell *)initCellWithTable:(UITableView *)tableView{
    MKUpdateFirmwareHostTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:MKUpdateFirmwareHostTypeCellIdenty];
    if (!cell) {
        cell = [[MKUpdateFirmwareHostTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKUpdateFirmwareHostTypeCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.ipView];
        [self.contentView addSubview:self.urlView];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(125.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.ipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(25.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ipView.mas_right).mas_offset(17.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(buttonViewHeight);
    }];
}

#pragma mark - MKUpdateHostTypeCellProtocol
- (NSInteger)currentMode{
    return self.modeNumber;
}

#pragma mark - event method
- (void)ipViewPressed{
    self.modeNumber = 0;
    self.ipIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    self.urlIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
}

- (void)urlViewPressed{
    self.modeNumber = 1;
    self.ipIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    self.urlIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _msgLabel.text = @"Type";
    }
    return _msgLabel;
}

- (UIImageView *)ipIcon{
    if (!_ipIcon) {
        _ipIcon = [[UIImageView alloc] init];
        _ipIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    }
    return _ipIcon;
}

- (UIImageView *)urlIcon{
    if (!_urlIcon) {
        _urlIcon = [[UIImageView alloc] init];
        _urlIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    }
    return _urlIcon;
}

- (UIView *)ipView{
    if (!_ipView) {
        _ipView = [[UIView alloc] init];
        [_ipView addTapAction:self selector:@selector(ipViewPressed)];
        
        [_ipView addSubview:self.ipIcon];
        
        [self.ipIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_ipView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *ipLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        ipLabel.text = @"IP";
        [_ipView addSubview:ipLabel];
        [ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.ipIcon.mas_right).mas_offset(8.f);
            make.width.mas_equalTo(labelWidth);
            make.centerY.mas_equalTo(_ipView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _ipView;
}

- (UIView *)urlView{
    if (!_urlView) {
        _urlView = [[UIView alloc] init];
        [_urlView addTapAction:self selector:@selector(urlViewPressed)];
        
        [_urlView addSubview:self.urlIcon];
        
        [self.urlIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_urlView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *urlLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        urlLabel.text = @"URL";
        [_urlView addSubview:urlLabel];
        [urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.urlIcon.mas_right).mas_offset(8.f);
            make.width.mas_equalTo(labelWidth);
            make.centerY.mas_equalTo(_urlView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _urlView;
}

@end

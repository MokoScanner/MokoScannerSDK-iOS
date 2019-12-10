//
//  MKConfigServerConnectModeCell.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerConnectModeCell.h"

static CGFloat const iconWidth = 13.f;
static CGFloat const iconHeight = 13.f;

static NSString *const MKConfigServerConnectModeCellIdenty = @"MKConfigServerConnectModeCellIdenty";

@interface MKConfigServerConnectModeCell()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIView *tcpView;

@property (nonatomic, strong)UIImageView *tcpIcon;

@property (nonatomic, strong)UIView *sslOneView;

@property (nonatomic, strong)UIImageView *sslOneIcon;

@property (nonatomic, strong)UIView *sslTwoView;

@property (nonatomic, strong)UIImageView *sslTwoIcon;

@property (nonatomic, assign)NSInteger modeNumber;

@end

@implementation MKConfigServerConnectModeCell

+ (MKConfigServerConnectModeCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerConnectModeCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerConnectModeCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerConnectModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerConnectModeCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.tcpView];
        [self.contentView addSubview:self.sslOneView];
        [self.contentView addSubview:self.sslTwoView];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    CGFloat viewWidth = (kScreenWidth - 4 * 15.f) / 3;
    [self.tcpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(viewWidth);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(5.f);
        make.bottom.mas_equalTo(-5.f);
    }];
    [self.sslOneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(viewWidth);
        make.centerY.mas_equalTo(self.tcpView.mas_centerY);
        make.height.mas_equalTo(self.tcpView.mas_height);
    }];
    [self.sslTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(viewWidth);
        make.centerY.mas_equalTo(self.tcpView.mas_centerY);
        make.height.mas_equalTo(self.tcpView.mas_height);
    }];
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
    return @{@"connectMode":@(self.modeNumber)};
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    [self tcpViewPressed];
}

/**
 设置参数
 
 @param params 参数
 */
- (void)setParams:(id)params{
    self.modeNumber = [params integerValue];
    [self updateSSLIcons];
}

#pragma mark - event method
- (void)tcpViewPressed{
    if (self.modeNumber == 0) {
        return;
    }
    self.modeNumber = 0;
    [self updateSSLIcons];
    if ([self.delegate respondsToSelector:@selector(connectModeChanged:)]) {
        [self.delegate connectModeChanged:self.modeNumber];
    }
}

- (void)sslOneViewPressed{
    if (self.modeNumber == 1) {
        return;
    }
    self.modeNumber = 1;
    [self updateSSLIcons];
    if ([self.delegate respondsToSelector:@selector(connectModeChanged:)]) {
        [self.delegate connectModeChanged:self.modeNumber];
    }
}

- (void)sslTowViewPressed {
    if (self.modeNumber == 2) {
        return;
    }
    self.modeNumber = 2;
    [self updateSSLIcons];
    if ([self.delegate respondsToSelector:@selector(connectModeChanged:)]) {
        [self.delegate connectModeChanged:self.modeNumber];
    }
}

#pragma mark -
- (void)updateSSLIcons {
    if (self.modeNumber == 0) {
        self.tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
        self.sslOneIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.sslTwoIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        return;
    }
    if (self.modeNumber == 1) {
        self.tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.sslOneIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
        self.sslTwoIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        return;
    }
    self.tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    self.sslOneIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    self.sslTwoIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _msgLabel.text = @"Connect Mode";
    }
    return _msgLabel;
}

- (UIImageView *)tcpIcon{
    if (!_tcpIcon) {
        _tcpIcon = [[UIImageView alloc] init];
        _tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    }
    return _tcpIcon;
}

- (UIImageView *)sslOneIcon {
    if (!_sslOneIcon) {
        _sslOneIcon = [[UIImageView alloc] init];
        _sslOneIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    }
    return _sslOneIcon;
}

- (UIView *)tcpView{
    if (!_tcpView) {
        _tcpView = [[UIView alloc] init];
        [_tcpView addTapAction:self selector:@selector(tcpViewPressed)];
        
        [_tcpView addSubview:self.tcpIcon];
        
        [self.tcpIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_tcpView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *tcpLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        tcpLabel.font = MKFont(12.f);
        tcpLabel.text = @"TCP";
        [_tcpView addSubview:tcpLabel];
        [tcpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tcpIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_tcpView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _tcpView;
}

- (UIView *)sslOneView {
    if (!_sslOneView) {
        _sslOneView = [[UIView alloc] init];
        [_sslOneView addTapAction:self selector:@selector(sslOneViewPressed)];
        
        [_sslOneView addSubview:self.sslOneIcon];
        
        [self.sslOneIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_sslOneView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *sslLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        sslLabel.font = MKFont(12.f);
        sslLabel.text = @"One-way SSL";
        [_sslOneView addSubview:sslLabel];
        [sslLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.sslOneIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_sslOneView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _sslOneView;
}

- (UIImageView *)sslTwoIcon {
    if (!_sslTwoIcon) {
        _sslTwoIcon = [[UIImageView alloc] init];
    }
    return _sslTwoIcon;
}

- (UIView *)sslTwoView {
    if (!_sslTwoView) {
        _sslTwoView = [[UIView alloc] init];
        [_sslTwoView addTapAction:self selector:@selector(sslTowViewPressed)];
        
        [_sslTwoView addSubview:self.sslTwoIcon];
        
        [self.sslTwoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_sslTwoView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *sslLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        sslLabel.font = MKFont(12.f);
        sslLabel.text = @"Two-way SSL";
        [_sslTwoView addSubview:sslLabel];
        [sslLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.sslTwoIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_sslTwoView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _sslTwoView;
}

@end

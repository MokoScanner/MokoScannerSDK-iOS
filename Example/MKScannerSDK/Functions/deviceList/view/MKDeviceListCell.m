//
//  MKDeviceListCell.m
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceListCell.h"

static NSString *const MKDeviceListCellIdenty = @"MKDeviceListCellIdenty";

static CGFloat const deviceIconWidth = 50.f;
static CGFloat const deviceIconHeight = 50.f;
static CGFloat const nextIconWidth = 8.f;
static CGFloat const nextIconHeight = 15.f;

static CGFloat const deleteButtonWidth = 75.0f;

@interface MKDeviceListCell ()

/**
 所有标签都位于这个上面
 */
@property (nonatomic, strong)UIView *contentPanel;

/**
 删除按钮所在view
 */
@property (nonatomic, strong)UIView *backGroundView;

/**
 删除按钮
 */
@property (nonatomic, strong)UIButton *deleteBtn;

@property (nonatomic, strong)UIImageView *deviceIcon;

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UILabel *deviceStateLabel;

@property (nonatomic, strong)UIImageView *nextIcon;

/**
 是否需要重新设置cell子控件坐标，
 */
@property (nonatomic, assign)BOOL shouldSetFrame;

@end

@implementation MKDeviceListCell

+ (MKDeviceListCell *)initCellWithTableView:(UITableView *)tableView{
    MKDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:MKDeviceListCellIdenty];
    if (!cell) {
        cell = [[MKDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKDeviceListCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.backGroundView];
        [self.backGroundView addSubview:self.deleteBtn];
        [self.contentView addSubview:self.contentPanel];
        [self.contentPanel addSubview:self.deviceIcon];
        [self.contentPanel addSubview:self.deviceNameLabel];
        [self.contentPanel addSubview:self.deviceStateLabel];
        [self.contentPanel addSubview:self.nextIcon];
        [self addSwipeGestureRecognizer];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentPanel setFrame:self.contentView.bounds];
    [self.backGroundView setFrame:self.contentView.bounds];
    
    [self.deviceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(deviceIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(deviceIconHeight);
    }];
    CGSize nameSize = [NSString sizeWithText:self.deviceNameLabel.text
                                     andFont:self.deviceNameLabel.font
                                  andMaxSize:CGSizeMake(MAXFLOAT, MKFont(15.f).lineHeight)];
    CGFloat width = MIN(nameSize.width, kScreenWidth - 5 * 15.f - deviceIconWidth - nextIconWidth);
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceIcon.mas_right).mas_offset(15.f);
        make.width.mas_equalTo(width);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.nextIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(nextIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(nextIconHeight);
    }];
    [self.deviceStateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceIcon.mas_right).mas_offset(15.f);
        make.width.mas_equalTo(100.f);
        make.bottom.mas_equalTo(-20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.deleteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(deleteButtonWidth);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - event method
- (void)deleteBtnPressed{
    if ([self.delegate respondsToSelector:@selector(cellDeleteButtonPressed:)]) {
        [self.delegate cellDeleteButtonPressed:self.indexPath];
    }
}

- (void)cellSelected{
    if (_contentPanel.frame.origin.x == 0) {
        if ([self.delegate respondsToSelector:@selector(cellSelected:)]) {
            [self.delegate cellSelected:self.indexPath];
        }
    }else if (_contentPanel.frame.origin.x < 0){
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _contentPanel.frame;
            frame.origin.x += deleteButtonWidth;
            _contentPanel.frame = frame;
            _shouldSetFrame = NO;
        }];
    }
}

- (void)swipeEventBeTriggered:(UISwipeGestureRecognizer *)swipeGesture{
    if ([self.delegate respondsToSelector:@selector(cellResetFrame)]) {
        [self.delegate cellResetFrame];
    }
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft){
        if (_contentPanel.frame.origin.x == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = _contentPanel.frame;
                frame.origin.x -= deleteButtonWidth;
                _contentPanel.frame = frame;
                _shouldSetFrame = YES;
            }];
        }
    }
    else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight){
        if (_contentPanel.frame.origin.x < 0) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = _contentPanel.frame;
                frame.origin.x += deleteButtonWidth;
                _contentPanel.frame = frame;
                _shouldSetFrame = NO;
            }];
        }
    }
}

#pragma mark - public method
- (void)resetCellFrame{
    if (_shouldSetFrame
        && _contentPanel.frame.origin.x < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _contentPanel.frame;
            frame.origin.x += deleteButtonWidth;
            _contentPanel.frame = frame;
            _shouldSetFrame = NO;
        }];
    }
}

- (BOOL)canReset{
    return _shouldSetFrame;
}

- (void)resetFlagForFrame{
    _shouldSetFrame = NO;
}

#pragma mark - setter
- (void)setDataModel:(MKDeviceModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.device_name)) {
        self.deviceNameLabel.text = _dataModel.device_name;
    }
    self.deviceIcon.image = LOADIMAGE(@"device_scanner_icon", @"png");
    if (_dataModel.plugState == MKBLEGatewayOnline) {
        self.deviceStateLabel.textColor = UIColorFromRGB(0x0188cc);
        self.deviceStateLabel.text = @"On-line";
    }else{
        self.deviceStateLabel.textColor = UIColorFromRGB(0xcccccc);
        self.deviceStateLabel.text = @"Off-line";
    }
    [self setNeedsLayout];
    return;
}

#pragma mark - private method
- (void)addSwipeGestureRecognizer{
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] init];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureLeft addTarget:self action:@selector(swipeEventBeTriggered:)];
    [self.contentPanel addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] init];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeGestureRight addTarget:self action:@selector(swipeEventBeTriggered:)];
    [self.contentPanel addGestureRecognizer:swipeGestureRight];
}

#pragma mark - getter
- (UIView *)contentPanel{
    if (!_contentPanel) {
        _contentPanel = [[UIView alloc] init];
        _contentPanel.backgroundColor = COLOR_WHITE_MACROS;
        [_contentPanel addTapAction:self selector:@selector(cellSelected)];
    }
    return _contentPanel;
}

- (UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.backgroundColor = COLOR_WHITE_MACROS;
        [_backGroundView addSubview:self.deleteBtn];
    }
    return _backGroundView;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.backgroundColor = [UIColor redColor];
        [_deleteBtn setTitle:@"delete" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIImageView *)deviceIcon{
    if (!_deviceIcon) {
        _deviceIcon = [[UIImageView alloc] init];
        _deviceIcon.image = LOADIMAGE(@"device_scanner_icon", @"png");
    }
    return _deviceIcon;
}

- (UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textColor = UIColorFromRGB(0x0188cc);
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
        _deviceNameLabel.font = MKFont(15.f);
    }
    return _deviceNameLabel;
}

- (UILabel *)deviceStateLabel{
    if (!_deviceStateLabel) {
        _deviceStateLabel = [[UILabel alloc] init];
        _deviceStateLabel.textColor = UIColorFromRGB(0x0188cc);
        _deviceStateLabel.textAlignment = NSTextAlignmentLeft;
        _deviceStateLabel.font = MKFont(15.f);
    }
    return _deviceStateLabel;
}

- (UIImageView *)nextIcon{
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] init];
        _nextIcon.image = LOADIMAGE(@"rightNextIcon", @"png");
    }
    return _nextIcon;
}

@end

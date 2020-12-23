//
//  MKFilterRawMsgCell.m
//  MKBLEGateway
//
//  Created by aa on 2020/5/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterRawMsgCell.h"

@interface MKFilterRawMsgCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UIButton *subButton;

@property (nonatomic, strong)UIButton *addButton;

@end

@implementation MKFilterRawMsgCell

+ (MKFilterRawMsgCell *)initCellWithTableView:(UITableView *)tableView {
    MKFilterRawMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKFilterRawMsgCellIdenty"];
    if (!cell) {
        cell = [[MKFilterRawMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKFilterRawMsgCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.subButton];
        [self.contentView addSubview:self.addButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(50.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.subButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchButton.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.switchButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.subButton.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.switchButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(150.f);
        make.centerY.mas_equalTo(self.switchButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)switchButtonPressed {
    self.switchButton.selected = !self.switchButton.selected;
    [self reloadSubViews];
    if ([self.delegate respondsToSelector:@selector(filterRawDataStatusChanged:)]) {
        [self.delegate filterRawDataStatusChanged:self.switchButton.selected];
    }
}

- (void)addButtonPressed {
    if ([self.delegate respondsToSelector:@selector(addFilterRawDataConditions)]) {
        [self.delegate addFilterRawDataConditions];
    }
}

- (void)subButtonPressed {
    if ([self.delegate respondsToSelector:@selector(subFilterRawDataConditions)]) {
        [self.delegate subFilterRawDataConditions];
    }
}

#pragma mark - setter
- (void)setFilterIsOn:(BOOL)filterIsOn {
    _filterIsOn = filterIsOn;
    self.switchButton.selected = _filterIsOn;
    [self reloadSubViews];
}

#pragma mark - private method
- (void)reloadSubViews {
    UIImage *buttonImage = (self.switchButton.selected ? LOADIMAGE(@"deviceList_switchStateOnIcon", @"png") : LOADIMAGE(@"deviceList_switchStateOffIcon", @"png"));
    [self.switchButton setImage:buttonImage forState:UIControlStateNormal];
    [self.addButton setHidden:!self.switchButton.selected];
    [self.subButton setHidden:!self.switchButton.selected];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.text = @"Raw Data Filter";
    }
    return _msgLabel;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:LOADIMAGE(@"deviceList_switchStateOffIcon", @"png") forState:UIControlStateNormal];
        [_switchButton addTapAction:self selector:@selector(switchButtonPressed)];
    }
    return _switchButton;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:LOADIMAGE(@"filterRawDataAddIcon", @"png") forState:UIControlStateNormal];
        [_addButton addTapAction:self selector:@selector(addButtonPressed)];
    }
    return _addButton;
}

- (UIButton *)subButton {
    if (!_subButton) {
        _subButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subButton setImage:LOADIMAGE(@"filterRawDataSubIcon", @"png") forState:UIControlStateNormal];
        [_subButton addTapAction:self selector:@selector(subButtonPressed)];
    }
    return _subButton;
}

@end

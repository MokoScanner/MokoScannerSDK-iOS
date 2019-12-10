//
//  MKAddDeviceView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceView.h"

@interface MKAddDeviceView()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *centerIcon;

@property (nonatomic, strong)UIButton *addButton;

@end

@implementation MKAddDeviceView
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.centerIcon];
        [self addSubview:self.addButton];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(52.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.centerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(130.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(130.f);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.right.mas_equalTo(-58.f);
        make.bottom.mas_equalTo(-70.f);
        make.height.mas_equalTo(50.f);
    }];
}

#pragma mark - event method
- (void)addButtonPressed{
    if (self.addDeviceBlock) {
        self.addDeviceBlock();
    }
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = UIColorFromRGB(0x0188cc);
        _msgLabel.font = MKFont(18.f);
        _msgLabel.text = @"Please add new device!";
    }
    return _msgLabel;
}

- (UIImageView *)centerIcon{
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
        _centerIcon.image = LOADIMAGE(@"mokoBLEGateway_centerIcon", @"png");
    }
    return _centerIcon;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Add Devices"
                                                              target:self
                                                              action:@selector(addButtonPressed)];
    }
    return _addButton;
}

@end

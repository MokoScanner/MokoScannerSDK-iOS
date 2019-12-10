//
//  MKAddDeviceController.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "MKAddDeviceDataManager.h"
#import "MKSaveDeviceNameController.h"

static CGFloat const offset_X = 20.f;

@interface MKAddDeviceController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)FLAnimatedImageView *gifIcon;

@property (nonatomic, strong)UILabel *linkLabel;

@property (nonatomic, strong)UIButton *blinkButton;

@property (nonatomic, strong)UILabel *instructionsLabel;

@property (nonatomic, strong)MKAddDeviceDataManager *dataManager;

@property (nonatomic, assign)CGFloat gifWidth;

@property (nonatomic, assign)CGFloat gifHeight;

@end

@implementation MKAddDeviceController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    self.dataManager.serverModel = self.configModel;
    self.dataManager.deviceParams = self.deviceParams;
    [self blinkButtonPressed];
    // Do any additional setup after loading the view.
}

#pragma mark - addDeviceControllerConfigProtocol
- (void)configAddDeviceController:(NSDictionary *)params{
    if (!ValidDict(params)) {
        return;
    }
    if (ValidStr(params[addDevice_messageKey])) {
        self.msgLabel.text = params[addDevice_messageKey];
    }
    if (ValidStr(params[addDevice_gifNameKey])) {
        NSString *imageName = [params[addDevice_gifNameKey] stringByAppendingString:(iPhone6Plus ? @"@3x" : @"@2x")];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"gif"];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        self.gifIcon.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
    }
    if (ValidStr(params[addDevice_linkMessageKey])) {
        self.linkLabel.text = params[addDevice_linkMessageKey];
    }
    if (ValidStr(params[addDevice_blinkButtonTitleKey])) {
        [self.blinkButton setTitle:params[addDevice_blinkButtonTitleKey] forState:UIControlStateNormal];
    }
    self.gifWidth = [params[addDevice_gifWidthKey] floatValue];
    self.gifHeight = [params[addDevice_gifHeightKey] floatValue];
}

#pragma mark - event method
- (void)linkLabelPressed{
    
}

- (void)blinkButtonPressed{
    WS(weakSelf);
    [self.dataManager startConfigProcessWithCompleteBlock:^(NSError *error, BOOL success, MKDeviceModel *deviceModel) {
        if (error) {
            [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
            return ;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
        MKSaveDeviceNameController *vc = [[MKSaveDeviceNameController alloc] init];
        MKDeviceModel *tempModel = [[MKDeviceModel alloc] init];
        [tempModel updatePropertyWithModel:deviceModel];
        vc.deviceModel = tempModel;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    self.defaultTitle = @"Add Device";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.msgLabel];
    [self.view addSubview:self.gifIcon];
    [self.view addSubview:self.linkLabel];
    [self.view addSubview:self.blinkButton];
    [self.view addSubview:self.instructionsLabel];
    
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(kScreenWidth - 2 * offset_X, MAXFLOAT)];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(24.f + defaultTopInset);
        make.height.mas_equalTo(msgSize.height);
    }];
    [self.gifIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.gifWidth);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(64.f);
        make.height.mas_equalTo(self.gifHeight);
    }];
    CGSize linkSize = [NSString sizeWithText:self.linkLabel.text
                                     andFont:self.linkLabel.font
                                  andMaxSize:CGSizeMake(MAXFLOAT,
                                                        (iPhone6Plus ? MKFont(17).lineHeight : MKFont(16).lineHeight))];
    [self.linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(linkSize.width);
        make.top.mas_equalTo(self.gifIcon.mas_bottom).mas_offset(64.f);
        make.height.mas_equalTo((iPhone6Plus ? MKFont(17).lineHeight : MKFont(16).lineHeight));
    }];
    [self.blinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.linkLabel.mas_bottom).mas_offset(25.f);
        make.height.mas_equalTo(45.f);
    }];
    [self.instructionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.blinkButton.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = UIColorFromRGB(0x808080);
        _msgLabel.font = MKFont(15.f);
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (FLAnimatedImageView *)gifIcon{
    if (!_gifIcon) {
        _gifIcon = [[FLAnimatedImageView alloc] init];
    }
    return _gifIcon;
}

- (UILabel *)linkLabel{
    if (!_linkLabel) {
        _linkLabel = [MKCommonlyUIHelper clickEnableLabelWithText:@""
                                                        textColor:UIColorFromRGB(0x0188cc)
                                                           target:self
                                                           action:@selector(linkLabelPressed)];
    }
    return _linkLabel;
}

- (UIButton *)blinkButton{
    if (!_blinkButton) {
        _blinkButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@""
                                                                target:self
                                                                action:@selector(blinkButtonPressed)];
    }
    return _blinkButton;
}

- (UILabel *)instructionsLabel{
    if (!_instructionsLabel) {
        _instructionsLabel = [[UILabel alloc] init];
        _instructionsLabel.textAlignment = NSTextAlignmentCenter;
        _instructionsLabel.textColor = UIColorFromRGB(0x808080);
        _instructionsLabel.font = MKFont(10.f);
        _instructionsLabel.numberOfLines = 0;
        _instructionsLabel.text = @"This app supports only 2.4GHz Wi-Fi network";
    }
    return _instructionsLabel;
}

- (MKAddDeviceDataManager *)dataManager{
    if (!_dataManager) {
        _dataManager = [MKAddDeviceDataManager addDeviceManager];
    }
    return _dataManager;
}

@end

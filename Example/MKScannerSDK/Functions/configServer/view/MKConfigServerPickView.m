//
//  MKConfigServerPickView.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerPickView.h"

static NSTimeInterval const animationDuration = .3f;
static CGFloat const kDatePickerH = 270;
static CGFloat const pickViewRowHeight = 30;

@interface MKConfigServerPickView()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)UIPickerView *pickView;

@property (nonatomic, strong)NSMutableArray <NSString *>*dataList;

@property (nonatomic, assign)NSInteger selectedRow;

@property (nonatomic, copy)void (^confirmBlock)(NSString *data, NSInteger selectedRow);

@end

@implementation MKConfigServerPickView

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.pickView];
        [self addTapAction:self selector:@selector(dismiss)];
    }
    return self;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return pickViewRowHeight;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataList.count;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *titleString = self.dataList[row];
    NSAttributedString *attributedString = [MKAttributedString getAttributedString:@[titleString] fonts:@[MKFont(15.f)] colors:@[DEFAULT_TEXT_COLOR]];
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedRow = row;
}

#pragma mark - event Method

/**
 取消选择
 */
- (void)cancelButtonPressed{
    [self dismiss];
}

/**
 确认选择
 */
- (void)confirmButtonPressed{
    if (self.confirmBlock) {
        self.confirmBlock(self.dataList[self.selectedRow], self.selectedRow);
    }
    [self dismiss];
}

- (void)dismiss{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - Public Method

/**
 显示选择器

 @param dataList 选择器数据源，必须是NSString
 @param currentData 当前选择器选中的数据
 @param block 选择之后点击确认按钮的回调
 */
- (void)showConfigServerPickViewWithDataList:(NSArray <NSString *>*)dataList
                                 currentData:(NSString *)currentData
                                       block:(void (^)(NSString *data, NSInteger selectedRow))block{
    if (!ValidArray(dataList) || !ValidStr(currentData) || ![dataList containsObject:currentData]) {
        return;
    }
    [kAppWindow addSubview:self];
    self.confirmBlock = nil;
    self.confirmBlock = block;
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:dataList];
    [self.pickView reloadAllComponents];
    self.selectedRow = [self getSelectedRowWithCurrentData:currentData];
    [self.pickView selectRow:self.selectedRow inComponent:0 animated:NO];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -kDatePickerH);
    }];
}

#pragma mark - private method
- (NSInteger)getSelectedRowWithCurrentData:(NSString *)currentData{
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        if ([currentData isEqualToString:self.dataList[i]]) {
            return i;
        }
    }
    return 0;
}

#pragma mark - setter & getter
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               kScreenHeight,
                                                               kScreenWidth,
                                                               kDatePickerH)];
        _bottomView.backgroundColor = RGBCOLOR(244, 244, 244);
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        topView.backgroundColor = COLOR_WHITE_MACROS;
        [_bottomView addSubview:topView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10, 10, 60, 30);
        [cancelButton setBackgroundColor:COLOR_CLEAR_MACROS];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:MKFont(16)];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:cancelButton];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame = CGRectMake(kScreenWidth - 10 - 60, 10, 60, 30);
        [confirmBtn setBackgroundColor:COLOR_CLEAR_MACROS];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [confirmBtn.titleLabel setFont:MKFont(16)];
        [confirmBtn addTarget:self action:@selector(confirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:confirmBtn];
    }
    return _bottomView;
}

- (UIPickerView *)pickView{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(10,
                                                                   kDatePickerH - 216,
                                                                   self.frame.size.width - 2 * 10,
                                                                   216)];
        // 显示选中框,iOS10以后分割线默认的是透明的，并且默认是显示的，设置该属性没有意义了，
        _pickView.showsSelectionIndicator = YES;
        _pickView.dataSource = self;
        _pickView.delegate = self;
        _pickView.backgroundColor = COLOR_CLEAR_MACROS;
    }
    return _pickView;
}
- (NSMutableArray<NSString *> *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end

//
//  MKConfigServerPickView.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKConfigServerPickView : UIView

/**
 显示选择器
 
 @param dataList 选择器数据源，必须是NSString
 @param currentData 当前选择器选中的数据
 @param block 选择之后点击确认按钮的回调
 */
- (void)showConfigServerPickViewWithDataList:(NSArray <NSString *>*)dataList
                                 currentData:(NSString *)currentData
                                       block:(void (^)(NSString *data, NSInteger selectedRow))block;

@end

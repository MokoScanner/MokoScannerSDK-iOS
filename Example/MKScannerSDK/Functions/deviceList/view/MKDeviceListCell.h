//
//  MKNewDeviceListCell.h
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKDeviceListCellDelegate <NSObject>

@optional

/**
 cell被点击了
 
 @param path cell所在path
 */
- (void)cellSelected:(NSIndexPath *)path;

/**
 删除按钮点击事件
 
 @param path cell所在path
 */
- (void)cellDeleteButtonPressed:(NSIndexPath *)path;

/**
 重新设置cell的子控件位置，主要是删除按钮方面的处理
 */
- (void)cellResetFrame;


@end

@interface MKDeviceListCell : MKBaseCell

@property (nonatomic, strong)MKDeviceModel *dataModel;

@property (nonatomic, weak)id <MKDeviceListCellDelegate>delegate;

+ (MKDeviceListCell *)initCellWithTableView:(UITableView *)tableView;

- (BOOL)canReset;

- (void)resetCellFrame;

- (void)resetFlagForFrame;

@end

NS_ASSUME_NONNULL_END

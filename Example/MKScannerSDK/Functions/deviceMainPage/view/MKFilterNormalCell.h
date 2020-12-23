//
//  MKFilterNormalCell.h
//  MKBLEGateway
//
//  Created by aa on 2020/5/6.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKFilterNormalCellDelegate <NSObject>

- (void)fliterSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index;

- (void)filterContent:(NSString *)newValue index:(NSInteger)index;

@end

@class MKFilterNormalCellModel;
@interface MKFilterNormalCell : MKBaseCell

@property (nonatomic, strong)MKFilterNormalCellModel *dataModel;

@property (nonatomic, weak)id <MKFilterNormalCellDelegate>delegate;

+ (MKFilterNormalCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END

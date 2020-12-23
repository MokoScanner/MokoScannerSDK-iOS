//
//  MKFilterRawMsgCell.h
//  MKBLEGateway
//
//  Created by aa on 2020/5/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKFilterRawMsgCellDelegate <NSObject>

- (void)filterRawDataStatusChanged:(BOOL)isOn;

- (void)addFilterRawDataConditions;

- (void)subFilterRawDataConditions;

@end

@interface MKFilterRawMsgCell : MKBaseCell

@property (nonatomic, assign)BOOL filterIsOn;

@property (nonatomic, weak)id <MKFilterRawMsgCellDelegate>delegate;

+ (MKFilterRawMsgCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END

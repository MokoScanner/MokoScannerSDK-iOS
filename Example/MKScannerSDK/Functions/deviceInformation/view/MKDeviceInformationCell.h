//
//  MKDeviceInformationCell.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKDeviceInformationModel;
@interface MKDeviceInformationCell : MKBaseCell

@property (nonatomic, strong)MKDeviceInformationModel *dataModel;

+ (MKDeviceInformationCell *)initCellWithTableView:(UITableView *)tableView;

+ (CGFloat)fetchCurrentCellHeight:(MKDeviceInformationModel *)dataModel;

@end

NS_ASSUME_NONNULL_END

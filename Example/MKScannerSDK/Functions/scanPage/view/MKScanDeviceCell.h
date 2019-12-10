//
//  MKScanDeviceCell.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKScanDeviceModel;
@interface MKScanDeviceCell : MKBaseCell

@property (nonatomic, strong)MKScanDeviceModel *dataModel;

+ (MKScanDeviceCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END

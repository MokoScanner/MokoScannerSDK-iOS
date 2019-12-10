//
//  MKDeviceInfoCell.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@class MKDeviceInfoModel;
@interface MKDeviceInfoCell : MKBaseCell

@property (nonatomic, strong)MKDeviceInfoModel *dataModel;

+ (MKDeviceInfoCell *)initCellWithTableView:(UITableView *)tableView;

@end

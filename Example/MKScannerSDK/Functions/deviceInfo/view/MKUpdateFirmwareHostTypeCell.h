//
//  MKUpdateFirmwareHostTypeCell.h
//  MKBLEGateway
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@protocol MKUpdateHostTypeCellProtocol <NSObject>

- (NSInteger)currentMode;

@end

@interface MKUpdateFirmwareHostTypeCell : MKBaseCell<MKUpdateHostTypeCellProtocol>

+ (MKUpdateFirmwareHostTypeCell *)initCellWithTable:(UITableView *)tableView;

@end

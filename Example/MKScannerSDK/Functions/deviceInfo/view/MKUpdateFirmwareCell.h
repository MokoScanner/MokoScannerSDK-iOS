//
//  MKUpdateFirmwareCell.h
//  MKBLEGateway
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@protocol MKUpdateCellProtocol <NSObject>

- (NSString *)currentValue;

@end

@interface MKUpdateFirmwareCell : MKBaseCell<MKUpdateCellProtocol>

@property (nonatomic, copy)NSString *msg;

+ (MKUpdateFirmwareCell *)initCellWithTable:(UITableView *)tableView;

- (void)hiddenKeyBoard;

@end

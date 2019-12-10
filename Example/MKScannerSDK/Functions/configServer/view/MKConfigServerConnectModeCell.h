//
//  MKConfigServerConnectModeCell.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConfigServerCellProtocol.h"

@protocol MKConnectModeCellDelegate <NSObject>

- (void)connectModeChanged:(NSInteger)mode;

@end

@interface MKConfigServerConnectModeCell : UITableViewCell<MKConfigServerCellProtocol>

@property (nonatomic, weak)id <MKConnectModeCellDelegate>delegate;

+ (MKConfigServerConnectModeCell *)initCellWithTableView:(UITableView *)tableView;

@end

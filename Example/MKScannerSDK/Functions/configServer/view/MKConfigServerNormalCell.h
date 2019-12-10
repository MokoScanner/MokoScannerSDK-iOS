//
//  MKConfigServerNormalCell.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConfigServerCellProtocol.h"

@interface MKConfigServerNormalCell : UITableViewCell<MKConfigServerCellProtocol>

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, strong, readonly)UITextField *textField;

@property (nonatomic, assign)BOOL secureTextEntry;

+ (MKConfigServerNormalCell *)initCellWithTableView:(UITableView *)tableView;

@end

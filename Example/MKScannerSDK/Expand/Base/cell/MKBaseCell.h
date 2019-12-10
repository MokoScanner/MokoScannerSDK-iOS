//
//  MKBaseCell.h
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKBaseCell : UITableViewCell

@property (nonatomic, strong)NSIndexPath *indexPath;

+ (CGFloat)getCellHeight;

@end

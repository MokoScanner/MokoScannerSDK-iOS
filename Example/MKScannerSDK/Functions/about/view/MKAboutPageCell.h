//
//  MKAboutPageCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MKAboutCellModel;
@interface MKAboutPageCell : UITableViewCell

@property (nonatomic, strong)MKAboutCellModel *dataModel;

+ (MKAboutPageCell *)initCellWithTableView:(UITableView *)table;

@end

NS_ASSUME_NONNULL_END

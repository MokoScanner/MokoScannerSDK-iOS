//
//  MKAboutCellModel.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKAboutCellModel : NSObject

@property (nonatomic, copy)NSString *typeMessage;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, copy)NSString *iconName;

@property (nonatomic, assign)BOOL canAdit;

@end

NS_ASSUME_NONNULL_END

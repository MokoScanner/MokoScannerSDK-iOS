//
//  MKEditFilterController.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKEditFilterControllerDelegate <NSObject>

- (void)needUpdateFilterRssi:(NSString *)rssi filterDeviceName:(NSString *)deviceName;

@end

@interface MKEditFilterController : MKBaseViewController

@property (nonatomic, strong)MKDeviceModel *deviceModel;

@property (nonatomic, weak)id <MKEditFilterControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END

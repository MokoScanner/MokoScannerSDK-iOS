//
//  MKDeviceMainPageIntervalView.h
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKDeviceMainPageIntervalViewDelegate <NSObject>

- (void)saveIntervalTime:(NSString *)interval;

@end

@interface MKDeviceMainPageIntervalView : UIView

@property (nonatomic, strong, readonly)UITextField *textField;

@property (nonatomic, strong, readonly)UILabel *totalLabel;

@property (nonatomic, weak)id <MKDeviceMainPageIntervalViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END

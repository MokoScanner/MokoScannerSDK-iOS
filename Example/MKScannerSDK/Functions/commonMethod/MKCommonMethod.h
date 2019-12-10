//
//  MKCommonMethod.h
//  MKBLEGateway
//
//  Created by aa on 2019/11/6.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCommonMethod : NSObject

+ (void)deleteDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target reset:(BOOL)reset;

@end

NS_ASSUME_NONNULL_END

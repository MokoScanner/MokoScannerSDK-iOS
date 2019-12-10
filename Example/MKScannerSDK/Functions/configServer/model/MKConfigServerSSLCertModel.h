//
//  MKConfigServerSSLCertModel.h
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConfigServerSSLCertModel : NSObject

@property (nonatomic, copy)NSString *msgTitle;

@property (nonatomic, copy)NSString *certName;

@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END

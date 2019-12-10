//
//  MKCertListController.h
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_certListPageType) {
    mk_caCertSelPage,
    mk_clientKeySelPage,
    mk_clientCertSelPage,
    mk_clientP12CertPage,
};

@protocol MKCertSelectedDelegate <NSObject>

- (void)mk_certSelectedMethod:(mk_certListPageType)certType certName:(NSString *)certName;

@end

@interface MKCertListController : MKBaseViewController

@property (nonatomic, weak)id <MKCertSelectedDelegate>delegate;

@property (nonatomic, assign)mk_certListPageType pageType;

@end

NS_ASSUME_NONNULL_END

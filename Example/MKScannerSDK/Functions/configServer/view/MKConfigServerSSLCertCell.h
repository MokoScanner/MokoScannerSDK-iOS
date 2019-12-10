//
//  MKConfigServerSSLCertCell.h
//  MKBLEGateway
//
//  Created by aa on 2019/7/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKConfigServerSSLCertCellDelegate <NSObject>

- (void)sslCertCellSelectedButtonPressed:(NSInteger)index;

@optional
- (void)sslCertCellTextFieldValueChanged:(NSString *)certName index:(NSInteger)index;

@end

@class MKConfigServerSSLCertModel;
@interface MKConfigServerSSLCertCell : UITableViewCell

@property (nonatomic, strong)MKConfigServerSSLCertModel *dataModel;

@property (nonatomic, weak)id <MKConfigServerSSLCertCellDelegate>delegate;

+ (MKConfigServerSSLCertCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END

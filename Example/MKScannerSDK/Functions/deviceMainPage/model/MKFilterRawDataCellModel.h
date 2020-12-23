//
//  MKFilterRawDataCellModel.h
//  MKBLEGateway
//
//  Created by aa on 2020/5/7.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKFilterRawDataCellModel : NSObject

@property (nonatomic, copy)NSString *dataType;

@property (nonatomic, copy)NSString *minIndex;

@property (nonatomic, copy)NSString *maxIndex;

@property (nonatomic, copy)NSString *rawData;

- (BOOL)validParamsSuccess;

@end

NS_ASSUME_NONNULL_END

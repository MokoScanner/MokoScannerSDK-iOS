//
//  MKBLETaskOperation.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/27.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MKBLETaskOperationID.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const mk_additionalInformation;
extern NSString *const mk_dataInformation;
extern NSString *const mk_dataStatusLev;

@interface MKBLETaskOperation : NSOperation<CBPeripheralDelegate>

/**
 Accept timer timeout, default is 2s.
 */
@property (nonatomic, assign)NSTimeInterval receiveTimeout;

/**
 Initialize the communication thread.
 
 @param operationID Current thread task ID.
 @param resetNum If need modify the total number of data that the task needs to accept according to the total number of data returned by the peripheral, YES needs, NO does not need.
 @param commandBlock send command to callback.
 @param completeBlock Data communication completion callback.
 @return operation
 */
- (instancetype)initOperationWithID:(mk_taskOperationID)operationID
                           resetNum:(BOOL)resetNum
                       commandBlock:(void (^)(void))commandBlock
                      completeBlock:(void (^)(NSError *error, mk_taskOperationID operationID, id returnData))completeBlock;

@end

NS_ASSUME_NONNULL_END

//
//  MKScannerCentralManager.h
//  MKBLEGateway
//
//  Created by aa on 2019/9/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKBLESDKDefines.h"
#import "MKBLETaskOperationID.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const mk_peripheralConnectStateChangedNotification;
extern NSString *const mk_centralManagerStateChangedNotification;

/*
 ****************************************** delegate ***************************************
 */
#pragma mark ****************************** delegate **********************************

#pragma mark - scanDelegate
@protocol mk_scanPeripheralDelegate <NSObject>
/**
 Central strat scanning method.
 
 */
- (void)mk_centralStartScan;
/**
 Central scan new.
 
 @param dataDic @{
 @"deviceName":(deviceName ? deviceName : @""),
 @"rssi":rssi,
 @"peripheral":peripheral
 }
 */
- (void)mk_centralDidDiscoverPeripheral:(NSDictionary *)dataDic;
/**
 Central stop scanning.
 
 */
- (void)mk_centralStopScan;

@end

#pragma mark - manager state delegate

@protocol mk_centralManagerStateDelegate <NSObject>

/**
 Central bluetooth status change.
 
 @param managerState central bluetooth status
 */
- (void)mk_centralStateChanged:(mk_centralManagerState)managerState;

/**
 Center and peripheral connection status change.
 
 @param connectState peripheral state
 */
- (void)mk_peripheralConnectStateChanged:(mk_peripheralConnectStatus)connectState;

@end

@class CBPeripheral;
@class CBCentralManager;
@class CBCharacteristic;
@class MKBLETaskOperation;
@interface MKScannerCentralManager : NSObject

/// centralManager
@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

/// Current connected device.
@property (nonatomic, strong, readonly)CBPeripheral *peripheral;

/// Current connection status.
@property (nonatomic, assign, readonly)mk_peripheralConnectStatus connectStatus;

/// Current bluetooth status.
@property (nonatomic, assign, readonly)mk_centralManagerState centralStatus;

/// Scan delegate.
@property (nonatomic, weak)id <mk_scanPeripheralDelegate>scanDelegate;

/// Central status delegate.
@property (nonatomic, weak)id <mk_centralManagerStateDelegate>stateDelegate;

+ (MKScannerCentralManager *)shared;
+ (void)attempDealloc;

#pragma mark - method

- (BOOL)scanDevice;

- (void)stopScan;

- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 sucBlock:(mk_connectSuccessBlock)sucBlock
              failedBlock:(mk_connectFailedBlock)failedBlock;
- (void)disconnectPeripheral;

/// Add a communication task (app-->peripheral) to the queue.
/// @param operationID Task ID.
/// @param characteristic Characteristics used in communication.
/// @param resetNum Is it necessary to return the total number of communication data by the peripheral.
/// @param commandData Communication data.
/// @param successBlock success callback
/// @param failureBlock failed callback
- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
           characteristic:(nonnull CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(nonnull NSString *)commandData
             successBlock:(mk_communicationSuccessBlock)successBlock
             failureBlock:(mk_communicationFailedBlock)failureBlock;
- (void)addTask:(nonnull MKBLETaskOperation *)task;

/// Send data to peripheral
/// @param commandData data
/// @param characteristic Characteristics used in communication.
- (void)sendCommandToPeripheral:(nonnull NSString *)commandData
                 characteristic:(nonnull CBCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END

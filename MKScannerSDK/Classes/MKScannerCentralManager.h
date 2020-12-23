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
 中心开始扫描
 
 */
- (void)mk_centralStartScan;
/**
 中心扫描到新的设备
 
 @param dataDic dataDic
 */
- (void)mk_centralDidDiscoverPeripheral:(NSDictionary *)dataDic;
/**
 中心停止扫描
 
 */
- (void)mk_centralStopScan;

@end

#pragma mark - manager state delegate

@protocol mk_centralManagerStateDelegate <NSObject>

/**
 中心蓝牙状态改变
 
 @param managerState 中心蓝牙状态
 */
- (void)mk_centralStateChanged:(mk_centralManagerState)managerState;

/**
 中心与外设连接状态改变
 
 @param connectState 外设连接状态
 */
- (void)mk_peripheralConnectStateChanged:(mk_peripheralConnectStatus)connectState;

@end

@class CBPeripheral;
@class CBCentralManager;
@class CBCharacteristic;
@class MKBLETaskOperation;
@interface MKScannerCentralManager : NSObject

@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

@property (nonatomic, strong, readonly)CBPeripheral *peripheral;

@property (nonatomic, assign, readonly)mk_peripheralConnectStatus connectStatus;

@property (nonatomic, assign, readonly)mk_centralManagerState centralStatus;

@property (nonatomic, weak)id <mk_scanPeripheralDelegate>scanDelegate;

@property (nonatomic, weak)id <mk_centralManagerStateDelegate>stateDelegate;

+ (MKScannerCentralManager *)shared;
+ (void)attempDealloc;

#pragma mark - method
- (BOOL)scanDevice;
- (void)stopScan;
- (void)connectPeripheral:(CBPeripheral *)peripheral
                 sucBlock:(mk_connectSuccessBlock)sucBlock
              failedBlock:(mk_connectFailedBlock)failedBlock;
- (void)disconnectPeripheral;

- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
           characteristic:(CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
             successBlock:(mk_communicationSuccessBlock)successBlock
             failureBlock:(mk_communicationFailedBlock)failureBlock;
- (void)addTask:(MKBLETaskOperation *)task;
- (void)sendCommandToPeripheral:(NSString *)commandData
                 characteristic:(CBCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END

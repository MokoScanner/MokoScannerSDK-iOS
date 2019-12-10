//
//  MKDeviceBLEConfigManager.m
//  MKBLEGateway
//
//  Created by aa on 2019/9/17.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceBLEConfigManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MKDeviceBLEConfigManager ()

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)dispatch_queue_t configQueue;

@end

@implementation MKDeviceBLEConfigManager

- (void)configDeviceDataWithWifiSSID:(NSString *)wifiSSID
                        wifiPassword:(NSString *)wifiPassword
                          peripheral:(CBPeripheral *)peripheral
                         serverModel:(MKConfigServerModel *)serverModel
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        NSError *error = [self connectPeripheral:peripheral];
        if (error) {
            moko_dispatch_main_safe(^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (![self configHost:serverModel.host]) {
            [self operationError:@"config host error" block:failedBlock];
            return;
        }
        if (![self configPort:[serverModel.port integerValue]]) {
            [self operationError:@"config port error" block:failedBlock];
            return;
        }
        if (![self configCleanSession:serverModel.cleanSession]) {
            [self operationError:@"config clean session error" block:failedBlock];
            return;
        }
        if (![self configDeviceID:serverModel.mqttID]) {
            [self operationError:@"config deviceID error" block:failedBlock];
            return;
        }
        if (![self configClientID:serverModel.clientId]) {
            [self operationError:@"config clientID error" block:failedBlock];
            return;
        }
        if (![self configUserName:serverModel.userName]) {
            [self operationError:@"config userName error" block:failedBlock];
            return;
        }
        if (![self configServerPassword:serverModel.password]) {
            [self operationError:@"config userName error" block:failedBlock];
            return;
        }
        if (![self configKeepAlive:[serverModel.keepAlive integerValue]]) {
            [self operationError:@"config keepAlive error" block:failedBlock];
            return;
        }
        if (![self configServerQos:[serverModel.qos integerValue]]) {
            [self operationError:@"config qos error" block:failedBlock];
            return;
        }
        if (![self configConnectMode:serverModel.connectMode]) {
            [self operationError:@"config connect mode error" block:failedBlock];
            return;
        }
        if (serverModel.connectMode != 0) {
            //单项或者双向
            NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *cafilePath = [document stringByAppendingPathComponent:serverModel.caFileName];
            NSData *caData = [NSData dataWithContentsOfFile:cafilePath];
            if (ValidData(caData)) {
                //需要配置CA证书
                if (![self configCAFiles:caData]) {
                    [self operationError:@"config CA file error" block:failedBlock];
                    return;
                }
            }
            if (serverModel.connectMode == 2) {
                //双向验证
                NSString *clientCertPath = [document stringByAppendingPathComponent:serverModel.clientCertName];
                NSData *clientCertData = [NSData dataWithContentsOfFile:clientCertPath];
                if (![self configClientCert:clientCertData]) {
                    [self operationError:@"config client cert error" block:failedBlock];
                    return;
                }
                NSString *clientKeyPath = [document stringByAppendingPathComponent:serverModel.clientKeyName];
                NSData *clientKeyData = [NSData dataWithContentsOfFile:clientKeyPath];
                if (![self configClientPrivateKey:clientKeyData]) {
                    [self operationError:@"config client private key error" block:failedBlock];
                    return;
                }
            }
        }
        if (![self configPublishTopic:serverModel.publishedTopic]) {
            [self operationError:@"config published topic error" block:failedBlock];
            return;
        }
        if (![self configSubscibeTopic:serverModel.subscribedTopic]) {
            [self operationError:@"config subscribed topic error" block:failedBlock];
            return;
        }
        if (![self configWifiSSID:wifiSSID]) {
            [self operationError:@"config wifiSSID error" block:failedBlock];
            return;
        }
        if (ValidStr(wifiPassword)) {
            if (![self configWifiPassword:wifiPassword]) {
                [self operationError:@"config wifi password error" block:failedBlock];
                return;
            }
        }
        if (![self deviceConnectServer]) {
            [self operationError:@"config device connect server error" block:failedBlock];
            return;
        }
        if (sucBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sucBlock();
            });
        }
    });
}

#pragma mark - interface
- (NSError *)connectPeripheral:(CBPeripheral *)peripheral {
    __block NSError *tempError = nil;
    [[MKScannerCentralManager shared] connectPeripheral:peripheral sucBlock:^(CBPeripheral *peripheral) {
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        tempError = error;
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return tempError;
}

- (BOOL)configHost:(NSString *)host {
    __block BOOL success = NO;
    [MKBLESDKInterface configServerHost:host sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPort:(NSInteger)port {
    __block BOOL success = NO;
    [MKBLESDKInterface configServerPort:port sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCleanSession:(BOOL)clean {
    __block BOOL success = NO;
    [MKBLESDKInterface configServerCleanSession:clean sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDeviceID:(NSString *)deviceID {
    __block BOOL success = NO;
    [MKBLESDKInterface configDeviceID:deviceID sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientID:(NSString *)clientID {
    __block BOOL success = NO;
    [MKBLESDKInterface configClientID:clientID sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configUserName:(NSString *)userName {
    __block BOOL success = NO;
    [MKBLESDKInterface configUserName:userName sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configServerPassword:(NSString *)passwrod {
    __block BOOL success = NO;
    [MKBLESDKInterface configPassword:passwrod sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configKeepAlive:(NSInteger)keepAlive {
    __block BOOL success = NO;
    [MKBLESDKInterface configKeepAlive:keepAlive sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configServerQos:(mqttServerQosMode)qos {
    __block BOOL success = NO;
    [MKBLESDKInterface configQos:qos sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configConnectMode:(mqttServerConnectMode)connectMode {
    __block BOOL success = NO;
    [MKBLESDKInterface configConnectMode:connectMode sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCAFiles:(NSData *)caData {
    __block BOOL success = NO;
    [MKBLESDKInterface configCAFile:caData sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientCert:(NSData *)clientCert {
    __block BOOL success = NO;
    [MKBLESDKInterface configClientCert:clientCert sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientPrivateKey:(NSData *)privateKey {
    __block BOOL success = NO;
    [MKBLESDKInterface configClientPrivateKey:privateKey sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPublishTopic:(NSString *)topic {
    __block BOOL success = NO;
    [MKBLESDKInterface configDevicePublishTopic:topic sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configSubscibeTopic:(NSString *)topic {
    __block BOOL success = NO;
    [MKBLESDKInterface configDeviceSubscibeTopic:topic sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiSSID:(NSString *)ssid {
    __block BOOL success = NO;
    [MKBLESDKInterface configWifiSSID:ssid sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifiPassword:(NSString *)password {
    __block BOOL success = NO;
    [MKBLESDKInterface configWifiPassword:password sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)deviceConnectServer {
    __block BOOL success = NO;
    [MKBLESDKInterface configDeviceConnectServerWithSucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark -
- (void)operationError:(NSString *)msg block:(void (^)(NSError *error))block {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.BLEConfig" code:-999 userInfo:@{@"errorInfo":msg}];
    moko_dispatch_main_safe(^{
        block(error);
    });
}

#pragma mark - setter & getter
- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("com.moko.configDeviceQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

@end

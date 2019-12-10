//
//  MKMQTTServerDataManager.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerDataManager.h"
#import "MKConfigServerModel.h"
#import "MQTTSSLSecurityPolicy.h"
#import <MQTTClient/MQTTSessionManager.h>
#import <MQTTClient/MQTTSSLSecurityPolicyTransport.h>
#import "MKMQTTSDKAdopter.h"

NSString *const MKMQTTSessionManagerStateChangedNotification = @"MKMQTTSessionManagerStateChangedNotification";

@interface MKMQTTServerDataManager()<MKMQTTServerManagerDelegate>

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@property (nonatomic, assign)MKMQTTSessionManagerState state;

@end

@implementation MKMQTTServerDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (instancetype)init{
    if (self = [super init]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.filePath = [documentPath stringByAppendingPathComponent:@"MQTTServerConfigForApp.txt"];
        self.paramDic = [[NSMutableDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!self.paramDic){
            self.paramDic = [NSMutableDictionary dictionary];
        }
        [self.configServerModel updateServerModelWithDic:self.paramDic];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:UIApplicationDidBecomeActiveNotification
                                         object:nil];
        [MKMQTTServerManager sharedInstance].delegate = self;
    }
    return self;
}

+ (MKMQTTServerDataManager *)sharedInstance{
    static MKMQTTServerDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerDataManager new];
        }
    });
    return manager;
}

#pragma mark - MKMQTTServerManagerDelegate
- (void)mqttServerManagerStateChanged:(MKMQTTSessionManagerState)state{
    self.state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTSessionManagerStateChangedNotification object:nil];
}

- (void)sessionManager:(MKMQTTServerManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic{
    if (!topic || !data || data.length < 5) {
        return;
    }
    NSString *function = [MKMQTTSDKAdopter hexStringFromData:[data subdataWithRange:NSMakeRange(0, 1)]];
    if ([function isEqualToString:mk_deviceKeepAliveStatusKey]) {
        //设备心跳包
        [self parseDeviceKeepAliveStatus:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_bleBroadcastDataKey]) {
        //网关扫描到的设备蓝牙广播数据
        [self parseBleBroadcastData:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_bluetoothStatusKey]) {
        //读取设备蓝牙状态
        [self parseBluetoothStatus:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_bluetoothScanTimeLengthKey]) {
        //读取设备蓝牙扫描时长
        [self parseBluetoothScanTimeLength:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_bleFilteringRssiKey]) {
        //读取设备蓝牙扫描时候过滤的rssi
        [self parseBleFilteringRssi:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_bleFilteringDeviceNameKey]) {
        //读取设备蓝牙扫描时候过滤的设备名称
        [self parseBleFilteringDeviceName:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_companyNameKey]) {
        //读取公司名称
        [self parseCompanyName:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_dateOfProductionKey]) {
        //读取生产日期
        [self parseDateOfProduction:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_deviceNameKey]) {
        //读取设备名称
        [self parseDeviceName:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_firmwareVersionKey]) {
        //读取固件版本
        [self parseFirmwareVersion:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_macAddressKey]) {
        //读取设备mac地址
        [self parseMacAddress:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_deviceProductModeKey]) {
        //读取产品型号
        [self parseDeviceProductMode:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_deviceUpdateResultKey]) {
        //设备固件升级结果
        [self parseDeviceUpdateResult:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
    if ([function isEqualToString:mk_resetFactoryKey]) {
        //设备恢复出厂设置
        [self parseResetFactory:[data subdataWithRange:NSMakeRange(1, data.length - 1)] topic:topic];
        return;
    }
}

#pragma mark - event method
- (void)networkStateChanged{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
        //如果是当前网络不可用，则断开当前手机与mqtt服务器的连接操作
        [[MKMQTTServerManager sharedInstance] disconnect];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnected
        || [MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnecting) {
        //已经连接或者正在连接，直接返回
        return;
    }
    //如果网络可用，则连接
    [self connectServer];
}

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

/**
 记录到本地
 */
- (void)synchronize{
    [self.paramDic setObject:SafeStr(self.configServerModel.host) forKey:@"host"];
    [self.paramDic setObject:SafeStr(self.configServerModel.port) forKey:@"port"];
    [self.paramDic setObject:@(self.configServerModel.cleanSession) forKey:@"cleanSession"];
    [self.paramDic setObject:@(self.configServerModel.connectMode) forKey:@"connectMode"];
    [self.paramDic setObject:SafeStr(self.configServerModel.qos) forKey:@"qos"];
    [self.paramDic setObject:SafeStr(self.configServerModel.keepAlive) forKey:@"keepAlive"];
    [self.paramDic setObject:SafeStr(self.configServerModel.clientId) forKey:@"clientId"];
    [self.paramDic setObject:SafeStr(self.configServerModel.userName) forKey:@"userName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.password) forKey:@"password"];
    [self.paramDic setObject:SafeStr(self.configServerModel.caFileName) forKey:@"caFileName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.clientP12CertName) forKey:@"clientP12CertName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.publishedTopic) forKey:@"publishedTopic"];
    [self.paramDic setObject:SafeStr(self.configServerModel.subscribedTopic) forKey:@"subscribedTopic"];
    
    [self.paramDic writeToFile:self.filePath atomically:NO];
};

/**
 连接mqtt server
 
 */
- (void)connectServer{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    MQTTSSLSecurityPolicy *securityPolicy = nil;
    NSArray *certList = nil;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (self.configServerModel.connectMode != 0) {
        //需要tls
        if (ValidStr(self.configServerModel.caFileName)) {
            NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.caFileName];
            NSData *clientCert = [NSData dataWithContentsOfFile:filePath];
            if (ValidData(clientCert)) {
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
                securityPolicy.pinnedCertificates = @[clientCert];
            }else {
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
            }
            securityPolicy.allowInvalidCertificates = YES;
            securityPolicy.validatesDomainName = NO;
            securityPolicy.validatesCertificateChain = NO;
        }
    }
    if (self.configServerModel.connectMode == 2) {
        //双向验证
        NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.clientP12CertName];
        certList = [MQTTSSLSecurityPolicyTransport clientCertsFromP12:filePath passphrase:@"123456"];
    }
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:self.configServerModel.host
                                                       port:[self.configServerModel.port integerValue]
                                                        tls:(self.configServerModel.connectMode != 0)
                                                  keepalive:[self.configServerModel.keepAlive integerValue]
                                                      clean:self.configServerModel.cleanSession
                                                       auth:YES
                                                       user:self.configServerModel.userName
                                                       pass:self.configServerModel.password
                                                   clientId:self.configServerModel.clientId
                                             securityPolicy:securityPolicy
                                               certificates:certList];
}

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData{
    MKConfigServerModel *model = [[MKConfigServerModel alloc] init];
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

#pragma mark - private method
- (void)parseDeviceKeepAliveStatus:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSData *statusData = [topicData subdataWithRange:NSMakeRange(index, dataLen)];
    //00离线，01在线
    NSString *status = [MKMQTTSDKAdopter hexStringFromData:statusData];
    NSDictionary *dataDic = @{
        @"function":mk_deviceKeepAliveStatusKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"status":status,
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDeviceKeepAliveStatusNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseBleBroadcastData:(NSData *)topicData topic:(NSString *)topic{
    if (topicData.length < 20) {
        return;
    }
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSInteger index = deviceID.length + 1;
    NSString *totalDataString = [MKMQTTSDKAdopter hexStringFromData:[topicData subdataWithRange:NSMakeRange(index, topicData.length - index)]];
    NSInteger totalDataNum = [MKMQTTSDKAdopter decimalWithHex:totalDataString range:NSMakeRange(0, 2)];
    NSString *broadString = [totalDataString substringWithRange:NSMakeRange(2, totalDataString.length - 2)];
    NSInteger subIndex = 0;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger i = 0; i < totalDataNum; i ++) {
        if (subIndex >= broadString.length) {
            break;
        }
        NSString *tempLenString = [broadString substringWithRange:NSMakeRange(subIndex, 2)];
        subIndex += 2;
        NSInteger temLen = [MKMQTTSDKAdopter decimalWithHex:tempLenString range:NSMakeRange(0, tempLenString.length)];
        NSString *tempBroadString = [broadString substringWithRange:NSMakeRange(subIndex, temLen * 2)];
        if (tempBroadString.length < 16) {
            break;
        }
        NSString *tempMac = [tempBroadString substringWithRange:NSMakeRange(0, 12)];
        NSString *mac = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[tempMac substringWithRange:NSMakeRange(0, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(10, 2)]];
        NSNumber *rssi = [MKMQTTSDKAdopter fetchRSSIWithContent:[MKMQTTSDKAdopter stringToData:[tempBroadString substringWithRange:NSMakeRange(12, 2)]]];
        NSInteger broadLen = [MKMQTTSDKAdopter decimalWithHex:tempBroadString range:NSMakeRange(14, 2)];
        if ((broadLen * 2) > (tempBroadString.length - 16)) {
            break;
        }
        NSString *rawData = [tempBroadString substringWithRange:NSMakeRange(16, broadLen * 2)];
        NSString *deviceName = @"";
        if (broadLen + 8 < temLen) {
            NSData *deviceNameData = [MKMQTTSDKAdopter stringToData:[tempBroadString substringWithRange:NSMakeRange(16 + 2 * broadLen, tempBroadString.length - (16 + 2 * broadLen))]];
            deviceName = [[NSString alloc] initWithData:deviceNameData encoding:NSUTF8StringEncoding];
        }
        NSDictionary *dic = @{
            @"macAddress":mac,
            @"rssi":rssi,
            @"rawData":rawData,
            @"deviceName":SafeStr(deviceName),
        };
        [dataList addObject:dic];
        subIndex += (temLen * 2);
    }
    NSDictionary *dataDic = @{
        @"function":mk_bleBroadcastDataKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":dataList,
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedBleBroadcastDataNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseBluetoothStatus:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSData *statusData = [topicData subdataWithRange:NSMakeRange(index, dataLen)];
    //00蓝牙关，01蓝牙开
    NSString *status = [MKMQTTSDKAdopter hexStringFromData:statusData];
    NSDictionary *dataDic = @{
        @"function":mk_bluetoothStatusKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"status":status,
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedBluetoothStatusNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseBluetoothScanTimeLength:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSData *scanIntervalData = [topicData subdataWithRange:NSMakeRange(index, dataLen)];
    NSString *tempData = [MKMQTTSDKAdopter hexStringFromData:scanIntervalData];
    NSString *scanInterval = [MKMQTTSDKAdopter decimalStringWithHex:tempData range:NSMakeRange(0, tempData.length)];
    NSDictionary *dataDic = @{
        @"function":mk_bluetoothScanTimeLengthKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"interval":scanInterval,
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedBluetoothScanTimeLengthNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseBleFilteringRssi:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSNumber *rssiValue = [MKMQTTSDKAdopter fetchRSSIWithContent:[topicData subdataWithRange:NSMakeRange(index, dataLen)]];
    NSDictionary *dataDic = @{
        @"function":mk_bleFilteringRssiKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"rssi":rssiValue,
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedBleFilteringRssiNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseBleFilteringDeviceName:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *filterName = [[NSString alloc] initWithData:[topicData subdataWithRange:NSMakeRange(index, dataLen)] encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = @{
        @"function":mk_bleFilteringDeviceNameKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"filterName":SafeStr(filterName),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedBleFilteringDeviceNameNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseCompanyName:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *companyName = [[NSString alloc] initWithData:[topicData subdataWithRange:NSMakeRange(index, dataLen)] encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = @{
        @"function":mk_companyNameKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"companyName":SafeStr(companyName),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedCompanyNameNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseDateOfProduction:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSData *tempDateOfProduction = [topicData subdataWithRange:NSMakeRange(index, dataLen)];
    NSString *temp = [MKMQTTSDKAdopter hexStringFromData:tempDateOfProduction];
    NSString *year = [MKMQTTSDKAdopter decimalStringWithHex:temp range:NSMakeRange(0, 4)];
    NSString *month = [MKMQTTSDKAdopter decimalStringWithHex:temp range:NSMakeRange(4, 2)];
    NSString *day = [MKMQTTSDKAdopter decimalStringWithHex:temp range:NSMakeRange(6, 2)];
    NSDictionary *dataDic = @{
        @"function":mk_dateOfProductionKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"dateOfProduction":[NSString stringWithFormat:@"%@.%@.%@",year,month,day],
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDateOfProductionNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseDeviceName:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *deviceName = [[NSString alloc] initWithData:[topicData subdataWithRange:NSMakeRange(index, dataLen)] encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = @{
        @"function":mk_deviceNameKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"deviceName":SafeStr(deviceName),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDeviceNameNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseFirmwareVersion:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *firmware = [[NSString alloc] initWithData:[topicData subdataWithRange:NSMakeRange(index, dataLen)] encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = @{
        @"function":mk_firmwareVersionKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"firmware":SafeStr(firmware),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedFirmwareVersionNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseMacAddress:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *macAddress = @"";
    NSString *tempMac = [MKMQTTSDKAdopter hexStringFromData:[topicData subdataWithRange:NSMakeRange(index, dataLen)]];
    if (tempMac.length == 12) {
        macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[tempMac substringWithRange:NSMakeRange(0, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(10, 2)]];
    }
    NSDictionary *dataDic = @{
        @"function":mk_macAddressKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"macAddress":SafeStr(macAddress),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedMacAddressNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseDeviceProductMode:(NSData *)topicData topic:(NSString *)topic {
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *productMode = [[NSString alloc] initWithData:[topicData subdataWithRange:NSMakeRange(index, dataLen)] encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = @{
        @"function":mk_deviceProductModeKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"productMode":SafeStr(productMode),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDeviceProductModeNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseDeviceUpdateResult:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *lenDic = [self fetchDeviceIDLenAndDataLen:topicData];
    NSInteger dataLen = [lenDic[@"dataLen"] integerValue];
    NSInteger index = [lenDic[@"index"] integerValue];
    NSString *tempData = [MKMQTTSDKAdopter hexStringFromData:[topicData subdataWithRange:NSMakeRange(index, dataLen)]];
    NSDictionary *dataDic = @{
        @"function":mk_deviceUpdateResultKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{
                @"result":@([tempData isEqualToString:@"01"]),
        },
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDeviceUpdateResultNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

- (void)parseResetFactory:(NSData *)topicData topic:(NSString *)topic{
    NSString *deviceID = [self fetchDeviceID:topicData];
    if (!ValidStr(deviceID)) {
        return;
    }
    NSDictionary *dataDic = @{
        @"function":mk_resetFactoryKey,
        @"id":deviceID,
        @"deviceTopic":topic,
        @"data":@{},
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedResetFactoryNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : dataDic}];
}

#pragma mark -
- (NSString *)fetchDeviceID:(NSData *)data {
    if (!ValidData(data) || data.length < 2) {
        return @"";
    }
    NSString *deviceIDlengthString = [MKMQTTSDKAdopter hexStringFromData:[data subdataWithRange:NSMakeRange(0, 1)]];
    NSInteger deviceIDLengh = [MKMQTTSDKAdopter decimalWithHex:deviceIDlengthString range:NSMakeRange(0, deviceIDlengthString.length)];
    NSString *deviceID = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, deviceIDLengh)] encoding:NSUTF8StringEncoding];
    return deviceID;
}

/// 获取topic数据里面的deviceID长度和数据域长度
/// @param topicData topicData
- (NSDictionary *)fetchDeviceIDLenAndDataLen:(NSData *)topicData {
    NSString *deviceIDlengthString = [MKMQTTSDKAdopter hexStringFromData:[topicData subdataWithRange:NSMakeRange(0, 1)]];
    NSString *deviceIDLengh = [MKMQTTSDKAdopter decimalStringWithHex:deviceIDlengthString range:NSMakeRange(0, deviceIDlengthString.length)];
    NSString *dataLenString = [MKMQTTSDKAdopter hexStringFromData:[topicData subdataWithRange:NSMakeRange([deviceIDLengh integerValue] + 1, 2)]];
    NSString *dataLen = [MKMQTTSDKAdopter decimalStringWithHex:dataLenString range:NSMakeRange(0, dataLenString.length)];
    NSInteger index = [deviceIDLengh integerValue] + 1 + 2;
    
    return @{
        @"deviceIDLen":deviceIDLengh,
        @"dataLen":dataLen,
        @"index":@(index),
    };
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end

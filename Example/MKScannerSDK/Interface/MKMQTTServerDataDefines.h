//公司名称
static NSString *const mk_companyNameKey = @"12";
//生产日期
static NSString *const mk_dateOfProductionKey = @"13";
//设备名称
static NSString *const mk_deviceNameKey = @"14";
//固件版本
static NSString *const mk_firmwareVersionKey = @"15";
//MAC地址
static NSString *const mk_macAddressKey = @"16";
//蓝牙开关状态
static NSString *const mk_bluetoothStatusKey = @"17";
//蓝牙扫描时长
static NSString *const mk_bluetoothScanTimeLengthKey = @"18";
//蓝牙扫描的时候过滤的rssi
static NSString *const mk_bleFilteringRssiKey = @"19";
//蓝牙扫描的时候过滤的设备名称
static NSString *const mk_bleFilteringDeviceNameKey = @"20";
//网关扫描到的设备蓝牙广播数据
static NSString *const mk_bleBroadcastDataKey = @"21";
//网关固件升级结果
static NSString *const mk_deviceUpdateResultKey = @"22";
//网关回复出厂设置
static NSString *const mk_resetFactoryKey = @"23";
//网关发布的联网状态
static NSString *const mk_deviceKeepAliveStatusKey = @"24";
//设备型号
static NSString *const mk_deviceProductModeKey = @"1a";
//设备LED设置
static NSString *const mk_deviceLEDSettingKey = @"1b";
//读取过滤蓝牙原始数据规则
static NSString *const mk_deviceRawFilterKey = @"1c";
//读取过滤mac地址规则
static NSString *const mk_deviceMacFilterKey = @"1d";
//读取数据超时时长
static NSString *const mk_deviceDataReportTimeKey = @"1e";


#pragma mark - 接收到MQTT服务器数据时候抛出的通知
//接收到了公司名称数据
static NSString *const MKMQTTServerReceivedCompanyNameNotification = @"MKMQTTServerReceivedCompanyNameNotification";
//接收到了生产日期数据
static NSString *const MKMQTTServerReceivedDateOfProductionNotification = @"MKMQTTServerReceivedDateOfProductionNotification";
//接收到了设备名称数据
static NSString *const MKMQTTServerReceivedDeviceNameNotification = @"MKMQTTServerReceivedDeviceNameNotification";
//接收到了固件版本数据
static NSString *const MKMQTTServerReceivedFirmwareVersionNotification = @"MKMQTTServerReceivedFirmwareVersionNotification";
//接收到了MAC地址数据
static NSString *const MKMQTTServerReceivedMacAddressNotification = @"MKMQTTServerReceivedMacAddressNotification";
//接收到了蓝牙开关状态
static NSString *const MKMQTTServerReceivedBluetoothStatusNotification = @"MKMQTTServerReceivedBluetoothStatusNotification";
//接收到了蓝牙扫描时长
static NSString *const MKMQTTServerReceivedBluetoothScanTimeLengthNotification = @"MKMQTTServerReceivedBluetoothScanTimeLengthNotification";
//接收到了蓝牙扫描的时候过滤的rssi
static NSString *const MKMQTTServerReceivedBleFilteringRssiNotification = @"MKMQTTServerReceivedBleFilteringRssiNotification";
//接收到了蓝牙扫描的时候过滤的设备名称
static NSString *const MKMQTTServerReceivedBleFilteringDeviceNameNotification = @"MKMQTTServerReceivedBleFilteringDeviceNameNotification";
//接收到了网关扫描到的设备蓝牙广播数据
static NSString *const MKMQTTServerReceivedBleBroadcastDataNotification = @"MKMQTTServerReceivedBleBroadcastDataNotification";
//接收到了网关固件升级结果
static NSString *const MKMQTTServerReceivedDeviceUpdateResultNotification = @"MKMQTTServerReceivedDeviceUpdateResultNotification";
//接收到了网关回复出厂设置
static NSString *const MKMQTTServerReceivedResetFactoryNotification = @"MKMQTTServerReceivedResetFactoryNotification";
//接收到了网关发布的联网状态
static NSString *const MKMQTTServerReceivedDeviceKeepAliveStatusNotification = @"MKMQTTServerReceivedDeviceKeepAliveStatusNotification";
//接收到了产品型号
static NSString *const MKMQTTServerReceivedDeviceProductModeNotification = @"MKMQTTServerReceivedDeviceProductModeNotification";
//接收到了LED设置
static NSString *const MKMQTTServerReceivedLEDSettingNotification = @"MKMQTTServerReceivedLEDSettingNotification";
//接收到了过滤蓝牙原始数据规则
static NSString *const MKMQTTServerReceivedRawFilterNotification = @"MKMQTTServerReceivedRawFilterNotification";
//接收到了过滤蓝牙mac地址
static NSString *const MKMQTTServerReceivedMacFilterNotification = @"MKMQTTServerReceivedMacFilterNotification";
//接收到了读取数据超时时长
static NSString *const MKMQTTServerReceivedDataReportTimeNotification = @"MKMQTTServerReceivedDataReportTimeNotification";

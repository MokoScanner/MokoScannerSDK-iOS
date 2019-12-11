# MokoScannerSDK-iOS
## 1、SDK集成
pod install MKScannerSDK.podspec
## 2、SDK简介

#### 2.1蓝牙部分
   app与设备之间通过蓝牙通信，主要用于配置设备的mqtt服务器、wifi等信息，使用的时候，在.pch文件里面引入MKScannerBLESDK.h即可.MKScannerCentralManager用来扫描设备，以及连接设备用来配置信息，MKBLESDKInterface用来配置具体的mqtt服务器、wifi信息，注意:所有信息都配置完成之后才能调用configDeviceConnectServerWithSucBlock:failedBlock:方法，设备会去连接mqtt服务器.

#### 2.2mqtt服务器通信部分
    MKMQTTServerManager用来实现APP与mqtt服务器通信，包括连接服务器、发布数据等.
由于设备目前通信只支持16进制数据，所以只能通过调用publishData:topic:sucBlock:failedBlock:方法发布数据给设备.

##### eg:读取设备的名字
//设置代理，接收服务器传过来的数据
/*
  - (void)sessionManager:(MKMQTTServerManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic {
    //mqtt服务器传过来的数据
  }
*/


[MKMQTTServerManager sharedInstance].delegate = self;

NSString *commandData = [NSString stringWithFormat:@"%@%@%@",@"14",mqttID,@"0000"];
[[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                            topic:topic
                                         sucBlock:sucBlock
                                      failedBlock:failedBlock];

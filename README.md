## Installation
#### 1、Add pod 'MKScannerSDK' to your Podfile.
#### 2、Run pod install or pod update.
#### 3、Import <MKScannerSDK/MKScannerBLESDK.h> and Import <MKScannerSDK/MKMQTTServerManager.h>

## MKSDKForBLE----SDK For BLE

   The app communicates with the device via Bluetooth, which is mainly used to configure the device's mqtt server, wifi and other information.MKScannerCentralManager is used to scan devices and connect devices. MKBLESDKInterface is used to configure specific mqtt server and wifi information. Note: After all the information is configured, you can call the configDeviceConnectServerWithSucBlock:failedBlock:method, and the device will connect to the mqtt server.

## MKMQTTServerManager---SDK For MQTT Server
   MKMQTTServerManager is used to implement communication between APP and mqtt server, including connecting to the server and publishing data.Because the device currently only supports hexadecimal data for communication, it can only publish data to the device by calling the publishData:topic:sucBlock:failedBlock: method.

## eg:Read device name
//Set up a delegate to receive data from the server
/*
  - (void)sessionManager:(MKMQTTServerManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic {
    //Data from the mqtt server
  }
*/


[MKMQTTServerManager sharedInstance].delegate = self;

NSString *commandData = [NSString stringWithFormat:@"%@%@%@",@"14",mqttID,@"0000"];
[[MKMQTTServerManager sharedInstance] publishData:[MKMQTTSDKAdopter stringToData:commandData]
                                            topic:topic
                                         sucBlock:sucBlock
                                      failedBlock:failedBlock];

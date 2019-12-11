
typedef NS_ENUM(NSInteger, mk_taskOperationID) {
    mk_defaultTaskOperationID,              //默认
    
#pragma mark - 读取
    mk_readLoraWANModemOperation,           //读取上传模式
    
#pragma mark - 设置
    mk_configServerHostNumberOperation,         //设置服务器host总包数
    mk_configServerHostOperation,               //设置服务器host
    mk_configServerPortOperation,               //设置服务器port
    mk_configServerCleanSessionOperation,       //设置服务器是否清除session
    mk_configDeviceIDNumberOperation,           //设置deviceID总包数
    mk_configDeviceIDOperation,                 //设置deviceID
    mk_configClientIDNumberOperation,           //设置clientID总包数
    mk_configClientIDOperation,                 //设置clientID
    mk_configUserNameNumberOperation,           //设置用户名总包数
    mk_configUserNameOperation,                 //设置用户名
    mk_configPasswordNumberOperation,           //设置密码总包数
    mk_configPasswordOperation,                 //设置密码
    mk_configServerKeepAliveOperation,          //设置keepAlive
    mk_configServerQosOperation,                //设置qos
    mk_configServerConnectModeOperation,        //设置服务器加密方式
    mk_configCAFileNumberOperation,             //设置CA证书总包数
    mk_configCAFileOperation,                   //设置CAs证书
    mk_configClientCertNumberOperation,         //设置客户端证书总包数
    mk_configClientCertOperation,               //设置客户端证书
    mk_configClientPrivateKeyNumberOperation,   //设置客户端私钥总包数
    mk_configClientPrivateKeyOperation,         //设置客户端私钥
    mk_configPublishTopicNumberOperation,       //设置发布主题总包数
    mk_configPublishTopicOperation,             //设置发布主题
    mk_configSubscibeTopicNumberOperation,      //设置订阅主题总包数
    mk_configSubscibeTopicOperation,            //设置订阅主题
    mk_configWifiSSIDNumberOperation,           //设置联网SSID总包数
    mk_configWifiSSIDOperation,                 //设置联网SSID
    mk_configWifiPasswordNumberOperation,       //设置联网密码总包数
    mk_configWifiPasswordOperation,             //设置联网密码
    mk_configDeviceConnectServerOperation,      //设备连接服务器
};

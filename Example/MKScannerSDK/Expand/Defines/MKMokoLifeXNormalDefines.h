//图片的宏定义
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@",file,(iPhone6Plus || iPhoneX || iPhoneMax) ? @"@3x" : @"@2x"] ofType:ext]]

/*
 添加设备成功的时候设备列表页面需要重新读取设备
 */
static NSString *const MKNeedReadDataFromLocalNotification = @"MKNeedReadDataFromLocalNotification";

/*
 对于智能面板，当分路开关名字发生改变的时候，需要设备列表页面更新
 */
static NSString *const MKNeedUpdateSwichWayNameNotification = @"MKNeedUpdateSwichWayNameNotification";

/*
 设备列表页面判定某个设备处于离线状态，抛出该通知
 */
static NSString *const MKDeviceOfflineNotification = @"MKDeviceOfflineNotification";

/*
 设备开始升级固件的时候，收到设备离线通知，不需要返回设备列表页面
 */
static NSString *const MKStartUpdateDeviceFirmwareNotification = @"MKStartUpdateDeviceFirmwareNotification";

/*
 设备升级固件完毕的时候，收到设备离线通知，需要返回设备列表页面
 */
static NSString *const MKStopUpdateDeviceFirmwareNotification = @"MKStopUpdateDeviceFirmwareNotification";

/** 设备列表数据库 路径*/
#define deviceDBPath              kFilePath(@"deviceDB")

/** 设备MQTT服务器配置数据库 路径*/
#define deviceMQTTServerDBPath              kFilePath(@"deviceMQTTServerDB")

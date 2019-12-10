
@class CBPeripheral;

#pragma mark - 字符串、字典、数组等类的验证宏定义
//*************************************字符串、字典、数组等类的验证宏定义******************************************************

#define mk_validStr(f)         (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define mk_validDict(f)        (f!=nil && [f isKindOfClass:[NSDictionary class]] && [f count]>0)
#define mk_validArray(f)       (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define mk_validData(f)        (f!=nil && [f isKindOfClass:[NSData class]])

typedef void(^mk_connectFailedBlock)(NSError *error);
typedef void(^mk_connectSuccessBlock)(CBPeripheral *peripheral);
typedef void(^mk_communicationSuccessBlock)(id returnData);
typedef void(^mk_communicationFailedBlock)(NSError *error);

#ifndef moko_main_safe
#define moko_main_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#pragma mark -
static NSString *const mk_communicationDataNum = @"mk_communicationDataNum";


typedef NS_ENUM(NSInteger, mk_peripheralConnectStatus) {
    mk_peripheralConnectStatusUnknow,                                           //Unknown state
    mk_peripheralConnectStatusConnecting,                                       //Connecting
    mk_peripheralConnectStatusConnected,                                        //Connect success
    mk_peripheralConnectStatusConnectedFailed,                                  //Connect fail
    mk_peripheralConnectStatusDisconnect,                                       //Disconnect
};
typedef NS_ENUM(NSInteger, mk_centralManagerState) {
    mk_centralManagerStateUnable,                           //Unavailable
    mk_centralManagerStateEnable,                           //Available
};

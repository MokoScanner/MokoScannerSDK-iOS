#import <UIKit/UIKit.h>

//动图上面的message
static NSString *const addDevice_messageKey = @"addDevice_messageKey";
//动图名称
static NSString *const addDevice_gifNameKey = @"addDevice_gifNameKey";
//中间gif宽度
static NSString *const addDevice_gifWidthKey = @"addDevice_gifWidthKey";
//中间gif高度
static NSString *const addDevice_gifHeightKey = @"addDevice_gifHeightKey";
//富文本message
static NSString *const addDevice_linkMessageKey = @"addDevice_linkMessageKey";
//底部按钮title
static NSString *const addDevice_blinkButtonTitleKey = @"addDevice_blinkButtonTitleKey";

@protocol addDeviceControllerConfigProtocol <NSObject>

/**
 目前插座和面板共用一个页面

 @param params 需要包含@{
    addDevice_messageKey:动图上面的message,
    addDevice_gifNameKey:动图名称,
    addDevice_gifWidthKey:gif宽度,
    addDevice_gifHeightKey:gif高度
    addDevice_linkMessageKey:富文本message,
    addDevice_blinkButtonTitleKey:底部按钮title
    addDevice_currentDeviceTypeKey:当前设备类型,currentDeviceType枚举
 }
 */
- (void)configAddDeviceController:(NSDictionary *)params;

@end

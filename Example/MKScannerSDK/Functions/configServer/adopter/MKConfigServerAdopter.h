//
//  MKConfigServerAdopter.h
//  MKBLEGateway
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKConfigServerCellProtocol.h"

//qos配置cell上面需要显示选择器，所有的textField需要隐藏键盘
static NSString *const configCellNeedHiddenKeyboardNotification = @"configCellNeedHiddenKeyboardNotification";

@class MKConfigServerModel;
@interface MKConfigServerAdopter : NSObject

+ (UILabel *)configServerDefaultMsgLabel;

+ (CGFloat)defaultMsgLabelHeight;

+ (NSArray *)configTopCellWithConfigModel:(MKConfigServerModel *)configModel
                                tableView:(UITableView *)tableView
                                    isApp:(BOOL)isApp;
/**
 所有带输入框的cell取消第一响应者
 */
+ (void)configCellResignFirstResponderWithTable:(UITableView *)tableView;

/**
 获取当前配置的服务器数据
 
 @param dataList dataList
 @param isApp 配置app的服务器信息还是设备的服务器信息
 @return model
 */
+ (MKConfigServerModel *)currentServerModelWithDataList:(NSArray <id<MKConfigServerCellProtocol>>*)dataList
                                                  isApp:(BOOL)isApp;

/**
 右上角清除按钮点了之后，将所有cell上面的信息恢复成默认的
 */
+ (void)clearAllConfigCellValuesWithTable:(UITableView *)tableView;

/**
 各项参数是否正确
 
 @param serverModel 当前配置的服务器参数
 @param target MKConfigServerController
 @return YES:正确，NO:存在参数错误
 */
+ (BOOL)checkConfigServerParams:(MKConfigServerModel *)serverModel target:(UIViewController *)target;

/**
 Qos选择

 @param currentData 当前Qos值
 @param confirmBlock 选择之后的回调
 */
+ (void)showQosPickViewWithCurrentData:(NSString *)currentData
                          confirmBlock:(void (^)(NSString *data, NSInteger selectedRow))confirmBlock;

@end

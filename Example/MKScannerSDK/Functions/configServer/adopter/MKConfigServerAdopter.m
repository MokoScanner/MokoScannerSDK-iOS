//
//  MKConfigServerAdopter.m
//  MKBLEGateway
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerAdopter.h"
#import "MKConfigServerHostCell.h"
#import "MKConfigServerPortCell.h"
#import "MKConfigServerConnectModeCell.h"
#import "MKConfigServerQosCell.h"
#import "MKConfigServerNormalCell.h"
#import "MKConfigServerPickView.h"
#import "MKConfigServerModel.h"
#import "twlt_uuid_util.h"

@implementation MKConfigServerAdopter

+ (UILabel *)configServerDefaultMsgLabel{
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    return msgLabel;
}

+ (CGFloat)defaultMsgLabelHeight{
    return MKFont(15.f).lineHeight;
}

+ (NSArray *)configTopCellWithConfigModel:(MKConfigServerModel *)configModel
                                tableView:(UITableView *)tableView
                                    isApp:(BOOL)isApp{
    NSMutableArray *dataList = [NSMutableArray array];
    //host
    MKConfigServerHostCell *hostCell = [MKConfigServerHostCell initCellWithTableView:tableView];
    [hostCell setParams:configModel.host];
    [dataList addObject:hostCell];
    
    //port
    MKConfigServerPortCell *portCell = [MKConfigServerPortCell initCellWithTableView:tableView];
    NSDictionary *params = @{
                             @"port":SafeStr(configModel.port),
                             @"clean":@(configModel.cleanSession)
                             };
    [portCell setParams:params];
    [dataList addObject:portCell];
    
    //Username
    MKConfigServerNormalCell *userNameCell = [MKConfigServerNormalCell initCellWithTableView:tableView];
    userNameCell.msg = @"Username";
    [userNameCell setParams:SafeStr(configModel.userName)];
    [dataList addObject:userNameCell];
    
    //Password
    MKConfigServerNormalCell *passwordCell = [MKConfigServerNormalCell initCellWithTableView:tableView];
    passwordCell.msg = @"Password";
    passwordCell.secureTextEntry = YES;
    [passwordCell setParams:SafeStr(configModel.password)];
    [dataList addObject:passwordCell];
    
    //qos
    MKConfigServerQosCell *qosCell = [MKConfigServerQosCell initCellWithTableView:tableView];
    NSDictionary *dic = @{
                          @"qos":SafeStr(configModel.qos),
                          @"keepAlive":SafeStr(configModel.keepAlive),
                          };
    [qosCell setParams:dic];
    [dataList addObject:qosCell];
    
    //client id
    MKConfigServerNormalCell *clientidCell = [MKConfigServerNormalCell initCellWithTableView:tableView];
    clientidCell.msg = @"Client Id";
    NSString *clientId = SafeStr(configModel.clientId);
    [clientidCell setParams:clientId];
    [dataList addObject:clientidCell];
    
    if (!isApp) {
        //设备端增加mqttID
        MKConfigServerNormalCell *mqttidCell = [MKConfigServerNormalCell initCellWithTableView:tableView];
        mqttidCell.msg = @"Device Id";
        NSString *mqttid = SafeStr(configModel.mqttID);
        [mqttidCell setParams:mqttid];
        [dataList addObject:mqttidCell];
    }
    
    //connect mode
    MKConfigServerConnectModeCell *connectModeCell = [MKConfigServerConnectModeCell initCellWithTableView:tableView];
    [connectModeCell setParams:@(configModel.connectMode)];
    [dataList addObject:connectModeCell];
    return dataList;
}

/**
 所有带输入框的cell取消第一响应者
 */
+ (void)configCellResignFirstResponderWithTable:(UITableView *)tableView{
    for (NSInteger row = 0; row < [tableView numberOfRowsInSection:0]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        id <MKConfigServerCellProtocol>cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(hiddenKeyBoard)]) {
            [cell hiddenKeyBoard];
        }
    }
}

+ (MKConfigServerModel *)currentServerModelWithDataList:(NSArray <id<MKConfigServerCellProtocol>>*)dataList
                                                  isApp:(BOOL)isApp{
    MKConfigServerModel *serverModel = [[MKConfigServerModel alloc] init];
    
    //host
    id <MKConfigServerCellProtocol>hostCell = dataList[0];
    NSDictionary *hostDic = [hostCell configServerCellValue];
    serverModel.host = hostDic[@"host"];
    
    //port
    id <MKConfigServerCellProtocol>portCell = dataList[1];
    NSDictionary *portDic = [portCell configServerCellValue];
    if (ValidStr(portDic[@"port"])) {
        serverModel.port = [NSString stringWithFormat:@"%ld",(long)[portDic[@"port"] integerValue]];
    }
    serverModel.cleanSession = [portDic[@"cleanSession"] boolValue];
    
    //userName
    id <MKConfigServerCellProtocol>userNameCell = dataList[2];
    NSDictionary *userNameDic = [userNameCell configServerCellValue];
    serverModel.userName = userNameDic[@"paramValue"];
    
    //password
    id <MKConfigServerCellProtocol>passwordCell = dataList[3];
    NSDictionary *passwordDic = [passwordCell configServerCellValue];
    serverModel.password = passwordDic[@"paramValue"];
    
    //qos
    id <MKConfigServerCellProtocol>qosCell = dataList[4];
    NSDictionary *qosDic = [qosCell configServerCellValue];
    serverModel.qos = qosDic[@"qos"];
    if (ValidStr(qosDic[@"keepAlive"])) {
        serverModel.keepAlive = [NSString stringWithFormat:@"%ld",(long)[qosDic[@"keepAlive"] integerValue]];
    }
    //client id
    id <MKConfigServerCellProtocol>clientIdCell = dataList[5];
    NSDictionary *clientIdDic = [clientIdCell configServerCellValue];
    serverModel.clientId = clientIdDic[@"paramValue"];
    
    if (isApp) {
        //connect mode
        id <MKConfigServerCellProtocol>connectModeCell = dataList[6];
        NSDictionary *connectModeDic = [connectModeCell configServerCellValue];
        serverModel.connectMode = [connectModeDic[@"connectMode"] integerValue];
    }else {
        //mqtt id
        id <MKConfigServerCellProtocol>mqttIdCell = dataList[6];
        NSDictionary *mqttIdDic = [mqttIdCell configServerCellValue];
        serverModel.mqttID = mqttIdDic[@"paramValue"];
        //connect mode
        id <MKConfigServerCellProtocol>connectModeCell = dataList[7];
        NSDictionary *connectModeDic = [connectModeCell configServerCellValue];
        serverModel.connectMode = [connectModeDic[@"connectMode"] integerValue];
    }
    
    return serverModel;
}

/**
 右上角清除按钮点了之后，将所有cell上面的信息恢复成默认的
 */
+ (void)clearAllConfigCellValuesWithTable:(UITableView *)tableView{
    NSInteger sectionNumber = [tableView numberOfSections];
    for (NSInteger i = 0; i < sectionNumber; i ++) {
        for (NSInteger row = 0; row < [tableView numberOfRowsInSection:i]; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:i];
            id <MKConfigServerCellProtocol>cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell respondsToSelector:@selector(setToDefaultParameters)]) {
                [cell setToDefaultParameters];
            }
        }
    }
}

/**
 Qos选择
 
 @param currentData 当前Qos值
 @param confirmBlock 选择之后的回调
 */
+ (void)showQosPickViewWithCurrentData:(NSString *)currentData
                          confirmBlock:(void (^)(NSString *data, NSInteger selectedRow))confirmBlock{
    NSArray *dataList = @[@"0",@"1",@"2"];
    MKConfigServerPickView *pickView = [[MKConfigServerPickView alloc] init];
    [pickView showConfigServerPickViewWithDataList:dataList currentData:currentData block:confirmBlock];
}

/**
 各项参数是否正确

 @param serverModel 当前配置的服务器参数
 @param target MKConfigServerController
 @return YES:正确，NO:存在参数错误
 */
+ (BOOL)checkConfigServerParams:(MKConfigServerModel *)serverModel target:(UIViewController *)target{
    if (!ValidStr(serverModel.host) && ![serverModel.host regularExpressions:isIPAddress]) {
        //host校验错误
        [target.view showCentralToast:@"Host error"];
        return NO;
    }
    if (serverModel.host.length > 63 || serverModel.host.length < 0) {
        //host校验错误
        [target.view showCentralToast:@"Host error"];
        return NO;
    }
    if (!ValidStr(serverModel.port)) {
        [target.view showCentralToast:@"Port error"];
        return NO;
    }
    if ([serverModel.port integerValue] < 0 || [serverModel.port integerValue] > 65535) {
        //port错误
        [target.view showCentralToast:@"Port range : 0~65535"];
        return NO;
    }
    if (!ValidStr(serverModel.keepAlive)) {
        [target.view showCentralToast:@"Keep alive range : 10~120"];
        return NO;
    }
    if ([serverModel.keepAlive integerValue] < 10 || [serverModel.keepAlive integerValue] > 120) {
        [target.view showCentralToast:@"Keep alive range : 10~120"];
        return NO;
    }
    //app，不能为空并且最大64个字符
    if (!ValidStr(serverModel.clientId) || serverModel.clientId.length > 64) {
        //client id错误
        [target.view showCentralToast:@"Client id error"];
        return NO;
    }
    if (serverModel.userName.length > 255) {
        //user name错误
        [target.view showCentralToast:@"User name error"];
        return NO;
    }
    if (serverModel.password.length > 255) {
        //passwrod错误
        [target.view showCentralToast:@"Password error"];
        return NO;
    }
    return YES;
}

@end

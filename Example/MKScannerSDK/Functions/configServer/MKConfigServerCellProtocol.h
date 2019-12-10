
@protocol MKConfigServerCellProtocol <NSObject>
/**
 获取当前cell显示的数值

 @return @{
    @"row":@(row),
    @"xx":@"xx"
    @"xx":@"xx"
 }
 */
- (NSDictionary *)configServerCellValue;

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters;

/**
 设置参数

 @param params 参数
 */
- (void)setParams:(id)params;

@optional

/**
 隐藏键盘
 */
- (void)hiddenKeyBoard;

@end

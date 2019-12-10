
@protocol MKConnectViewConfirmDelegate <NSObject>

/**
 connectView的确认按钮点击事件
 
 @param view connectView
 @param returnData 返回的数据
 */
- (void)confirmButtonActionWithView:(UIView *)view returnData:(id)returnData;

/**
 connectView的取消按钮点击事件

 @param view connectView
 */
- (void)cancelButtonActionWithView:(UIView *)view;

@end

@protocol MKConnectViewProtocol <NSObject>

//@property (nonatomic, weak)id <MKConnectViewConfirmDelegate>delegate;

/**
 加载页面
 */
- (void)showConnectAlertView;

/**
 移除页面
 */
- (void)dismiss;

/**
 当前页面是否加载在window上面了

 @return YES:正在展示，NO:没有呈现在window
 */
- (BOOL)isShow;

@end

//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>
#import <objc/message.h>

// 弱引用
#define MJWeakSelf __weak typeof(self) weakSelf = self;

// 日志输出
#ifdef DEBUG
#define YSFRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define YSFRefreshLog(...)
#endif

// 过期提醒
#define YSFRefreshDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 运行时objc_msgSend
#define YSFRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define YSFRefreshMsgTarget(target) (__bridge void *)(target)

// RGB颜色
#define YSFRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define YSFRefreshLabelTextColor YSFRefreshColor(90, 90, 90)

// 字体大小
#define YSFRefreshLabelFont [UIFont boldSystemFontOfSize:14]

// 常量
UIKIT_EXTERN const CGFloat YSFRefreshLabelLeftInset;
UIKIT_EXTERN const CGFloat YSFRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat YSFRefreshFooterHeight;
UIKIT_EXTERN const CGFloat YSFRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat YSFRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const YSFRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const YSFRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const YSFRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const YSFRefreshKeyPathPanState;

UIKIT_EXTERN NSString *const YSFRefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const YSFRefreshHeaderIdleText;
UIKIT_EXTERN NSString *const YSFRefreshHeaderPullingText;
UIKIT_EXTERN NSString *const YSFRefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const YSFRefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const YSFRefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const YSFRefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const YSFRefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const YSFRefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const YSFRefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const YSFRefreshBackFooterNoMoreDataText;

UIKIT_EXTERN NSString *const YSFRefreshHeaderLastTimeText;
UIKIT_EXTERN NSString *const YSFRefreshHeaderDateTodayText;
UIKIT_EXTERN NSString *const YSFRefreshHeaderNoneLastDateText;

// 状态检查
#define YSFRefreshCheckState \
YSFRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];

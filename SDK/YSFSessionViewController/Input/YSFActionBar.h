#define YSFActionBarHeight 45.0

typedef NS_ENUM(NSInteger, YSFActionType) {
    YSFActionTypeSend = 1,
    YSFActionTypeOpenUrl = 2,
};


@interface YSFActionInfo : NSObject

@property (nonatomic, assign) YSFActionType action;
@property (nonatomic, strong) id buttonId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id userData;

+ (YSFActionInfo *)dataByJson:(NSDictionary *)dict;

@end


typedef void (^SelectActionCallback)(YSFActionInfo *action);

@interface YSFActionBar : UIView

@property (nonatomic, copy) SelectActionCallback selectActionCallback;
@property (nonatomic, strong) NSArray *actionInfoArray;
@property (nonatomic, strong) UIScrollView *scrollView;

+ (CGFloat)heightForActionBar;

@end

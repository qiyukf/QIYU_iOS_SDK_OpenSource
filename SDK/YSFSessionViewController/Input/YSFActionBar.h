typedef NS_ENUM(NSInteger, QYActionType) {
    QYActionTypeSend,
    QYActionTypeOpenUrl,
};

@interface YSFActionInfo : NSObject

@property (nonatomic,assign)    QYActionType    action;
@property (nonatomic,assign)    NSInteger       id;
@property (nonatomic,copy)      NSString *      label;
@property (nonatomic,copy)      NSString *      url;

@end


typedef void (^SelectActionCallback)(YSFActionInfo *action);

@interface YSFActionBar : UIView

@property (nonatomic, copy) SelectActionCallback selectActionCallback;
@property (nonatomic, strong) NSArray *actionInfoArray;
@property (nonatomic,strong,readonly)    UIScrollView *scrollView;

@end

typedef NS_ENUM(NSInteger, QYActionType) {
    QYActionTypeSend = 1,
    QYActionTypeOpenUrl = 2,
};

@interface YSFActionInfo : NSObject

@property (nonatomic,assign)    QYActionType    action;
@property (nonatomic,strong)    id       buttonId;
@property (nonatomic,copy)      NSString *title;
@property (nonatomic,strong)    id      userData;

@end


typedef void (^SelectActionCallback)(YSFActionInfo *action);

@interface YSFActionBar : UIView

@property (nonatomic, copy) SelectActionCallback selectActionCallback;
@property (nonatomic, strong) NSArray *actionInfoArray;
@property (nonatomic,strong,readonly)    UIScrollView *scrollView;

@end

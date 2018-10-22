
@interface YSFNotification : NSObject <YSF_NIMCustomAttachment>
@property (nonatomic, assign) NSInteger command;
@property (nonatomic, assign) NSInteger localCommand;
@property (nonatomic, copy) NSString *message;
//未持久化
@property (nonatomic, assign) NSRange clickRange;
@property (nonatomic, strong) UIColor *clickColor;

+ (YSFNotification *)objectByDict:(NSDictionary *)dict;

@end

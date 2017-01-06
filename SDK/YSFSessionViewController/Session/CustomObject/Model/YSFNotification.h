
@interface YSFNotification : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,assign)    NSInteger   localCommand;
@property (nonatomic,copy)      NSString    *message;

+ (YSFNotification *)objectByDict:(NSDictionary *)dict;
@end

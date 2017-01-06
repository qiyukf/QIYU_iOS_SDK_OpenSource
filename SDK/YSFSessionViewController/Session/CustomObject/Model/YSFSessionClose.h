
@interface YSFSessionClose : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;

@property (nonatomic,assign)    int64_t sessionId;

@property (nonatomic,assign)    NSInteger closeType;

@property (nonatomic,strong)    NSString *message;

+ (YSFSessionClose *)objectByDict:(NSDictionary *)dict;
@end

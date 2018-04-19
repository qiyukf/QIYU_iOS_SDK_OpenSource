typedef enum : NSUInteger {
    YSFAuditResultTypeOK        = 0,      //正常
    YSFAuditResultTypeYidun              = 1,      //易盾关键词
    YSFAuditResultTypeTransWords      = 2,      //表示敏感词
} YSFAuditResultType;

@interface YSFTrashWords : NSObject

@property (nonatomic,assign)  long long sessionId;
@property (nonatomic,copy)    NSString *msgIdClient;
@property (nonatomic,copy)    NSArray *trashWords;
@property (nonatomic,assign)  YSFAuditResultType auditResultType;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

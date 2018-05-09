
@interface YSFMiniAppTimeout : NSObject

@property (nonatomic,assign)  long long sessionId;
@property (nonatomic,copy)    NSString *msgIdClient;
@property (nonatomic,copy)    NSString *info;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

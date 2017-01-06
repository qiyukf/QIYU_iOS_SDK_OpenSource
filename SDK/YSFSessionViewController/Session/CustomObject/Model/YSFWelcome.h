
@interface YSFWelcome : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;

@property (nonatomic,copy)      NSString    *userId;

@property (nonatomic,copy)      NSString    *deviceId;

@property (nonatomic,assign)    int64_t sessionId;

@property (nonatomic,copy)      NSString    *welcome;

+ (YSFWelcome *)objectByDict:(NSDictionary *)dict;
@end

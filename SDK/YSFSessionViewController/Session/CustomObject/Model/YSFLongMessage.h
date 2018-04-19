typedef enum : NSUInteger {
    YSFLongMessageTypeCustomMessage              = 1,
    YSFLongMessageTypeSystemNotification         = 2
} YSFLongMessageType;

@interface YSFLongMessage : NSObject

@property (nonatomic,assign)    YSFLongMessageType msgType;
@property (nonatomic,copy)    NSString *msgId;
@property (nonatomic,copy)    NSString *splitId;
@property (nonatomic,assign)    NSInteger splitCount;
@property (nonatomic,assign)    NSInteger splitIndex;
@property (nonatomic,copy)    NSString *splitContent;


+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

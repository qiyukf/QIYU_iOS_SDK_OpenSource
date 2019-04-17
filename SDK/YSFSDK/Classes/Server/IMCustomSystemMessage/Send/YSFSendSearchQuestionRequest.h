#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSendSearchQuestionRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)      long long sessionId;
@property (nonatomic,copy)      NSString *content;

@end

#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSendSearchQuestionRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)      long long sessionId;
@property (nonatomic,assign)      NSString *content;

@end

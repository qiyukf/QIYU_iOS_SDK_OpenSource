#import "YSFIMCustomSystemMessageApi.h"

@interface YSFPushMessageStatusChangeRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)      long long msgSessionId;
@property (nonatomic,assign)      NSInteger status;         //1:收到消息 2: 已读

@end

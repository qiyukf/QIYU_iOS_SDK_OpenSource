#import "YSFIMCustomSystemMessageApi.h"

@interface YSFSendInputtingMessageRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)      long long sessionId;
@property (nonatomic,copy)        NSString *content;
@property (nonatomic,assign)      long long endTime;
@property (nonatomic,assign)      CGFloat sendingRate;

@end

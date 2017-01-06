#import "YSFIMCustomSystemMessageApi.h"

@interface YSFEvaluationRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)    long long  sessionId;
@property (nonatomic,assign)    NSUInteger score;
@property (nonatomic,copy)      NSString *remarks;

@end

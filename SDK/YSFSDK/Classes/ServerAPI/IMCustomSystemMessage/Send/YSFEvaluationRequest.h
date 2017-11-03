#import "YSFIMCustomSystemMessageApi.h"

@interface YSFEvaluationRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)    long long  sessionId;
@property (nonatomic,assign)    NSUInteger score;
@property (nonatomic,copy)      NSString *remarks;
@property (nonatomic,strong)    NSArray *tagIds;

@end

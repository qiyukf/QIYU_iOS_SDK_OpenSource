#import "YSFIMCustomSystemMessageApi.h"

@interface YSFEvaluationAnswerRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,assign)    NSInteger  evaluation;
@property (nonatomic,copy)    NSString   *msgidClient;

@end

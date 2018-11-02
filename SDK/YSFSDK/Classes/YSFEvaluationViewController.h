
typedef void (^EvaluationCallback)(BOOL done, NSString *evaluationText);

@interface EvaluationData : NSObject



@end

@interface YSFEvaluationViewController : UIViewController

- (instancetype)initWithEvaluationDict:(NSDictionary *)evaluationDict shopId:(NSString *)shopId sessionId:(long long)sessionId evaluationCallback:(EvaluationCallback)evaluationCallback;

@end


typedef void (^EvaluationCallback)(BOOL done, NSString *evaluationText, NSString *remarks);

@interface EvaluationData : NSObject



@end

@interface YSFEvaluationViewController : UIViewController

- (instancetype)initWithEvaluationDict:(NSDictionary *)evaluationDict shopId:(NSString *)shopId sessionId:(long long)sessionId evaluationCallback:(EvaluationCallback)evaluationCallback;

@end

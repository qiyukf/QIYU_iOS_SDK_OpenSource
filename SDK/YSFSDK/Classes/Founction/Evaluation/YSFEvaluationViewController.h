

@interface YSFEvaluationCommitData : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, copy) NSString *content;

+ (instancetype)instanceByDict:(NSDictionary *)dict;
- (NSDictionary *)toDict;

@end


@class YSFEvaluationResult;
@class YSFEvaluationData;
typedef void (^evaluationCallback)(BOOL done, YSFEvaluationResult *result);

@interface YSFEvaluationViewController : UIViewController

- (instancetype)initWithEvaluationData:(YSFEvaluationData *)evaluationData
                      evaluationResult:(YSFEvaluationCommitData *)lastResult
                                shopId:(NSString *)shopId
                             sessionId:(long long)sessionId
                          modifyEnable:(BOOL)modifyEnable
                    evaluationCallback:(evaluationCallback)evaluationCallback;

@end

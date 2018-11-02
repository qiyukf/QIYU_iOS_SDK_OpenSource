

@interface YSFInviteEvaluationObject : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,assign)    long long       sessionId;
@property (nonatomic, strong)   NSDictionary *evaluationDict;
@property (nonatomic, copy)   NSString *evaluationMessageInvite;
@property (nonatomic, copy)   NSString *evaluationMessageThanks;
@property (nonatomic,assign)    BOOL evaluationAutoPopup;

+ (YSFInviteEvaluationObject *)objectByDict:(NSDictionary *)dict;

@end

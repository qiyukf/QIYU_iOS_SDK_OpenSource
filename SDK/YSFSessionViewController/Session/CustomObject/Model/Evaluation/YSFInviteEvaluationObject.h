

@interface YSFInviteEvaluationObject : NSObject <YSF_NIMCustomAttachment>

@property (nonatomic, assign) NSInteger command;
@property (nonatomic, assign) long long sessionId;

@property (nonatomic, strong) NSDictionary *evaluationData;  //评价模式及标签内容
@property (nonatomic, copy) NSString *inviteText;  //邀请评价文案
@property (nonatomic, copy) NSString *thanksText;  //感谢评价文案

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

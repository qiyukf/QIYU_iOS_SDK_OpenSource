
typedef NS_ENUM(NSInteger, YSFInviteEvaluateStatus) {
    YSFInviteEvaluateStatusHidden = 0,  //邀评按钮隐藏
    YSFInviteEvaluateStatusEnable,      //邀评按钮显示且可点击
    YSFInviteEvaluateStatusUnable,      //邀评按钮显示且置灰
};


@interface YSFInviteEvaluationObject : NSObject <YSF_NIMCustomAttachment>

@property (nonatomic, assign) NSInteger command;
@property (nonatomic, assign) NSInteger localCommand;
@property (nonatomic, assign) long long sessionId;
//访客端：客服发来的邀评消息数据
@property (nonatomic, strong) NSDictionary *evaluationData;  //评价模式及标签内容
@property (nonatomic, copy) NSString *inviteText;  //邀请评价文案
@property (nonatomic, copy) NSString *thanksText;  //感谢评价文案
@property (nonatomic, assign) NSInteger evaluationTimes;  //已评价次数
//客服端：访客提交的评价结果（客服可邀请访客评价）
@property (nonatomic, copy) NSString *evaluationResult;
@property (nonatomic, assign) YSFInviteEvaluateStatus inviteStatus;


+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

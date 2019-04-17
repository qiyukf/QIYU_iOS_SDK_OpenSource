#import "YSFInviteEvaluationObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFInviteEvaluationObject

- (NSString *)thumbText {
    if (_localCommand == YSFCommandInviteEvaluation) {
        return @"感谢您的咨询，请对我们的服务作出评价";
    } else if (_localCommand == YSFCommandSatisfactionResult) {
        return [NSString stringWithFormat:@"用户提交的服务评价为：%@", YSFStrParam(_evaluationResult)];
    }
    return @"[评价消息]";
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeyLocalCmd] = @(_localCommand);
    dict[YSFApiKeySessionId] = @(_sessionId);
    
    if (_evaluationData) {
        dict[YSFApiKeyEvaluationData] = [_evaluationData ysf_toUTF8String];
    }
    if (_inviteText) {
        dict[YSFApiKeyEvaluationInviteMsg] = _inviteText;
    }
    if (_thanksText) {
        dict[YSFApiKeyEvaluationThanksMsg] = _thanksText;
    }
    dict[YSFApiKeyEvaluationTimes] = @(_evaluationTimes);
    
    if (_evaluationResult) {
        dict[YSFApiKeyEvaluationResult] = _evaluationResult;
    }
    dict[YSFApiKeyEvaluationInviteStatus] = @(_inviteStatus);
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFInviteEvaluationObject *instance = [[YSFInviteEvaluationObject alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.localCommand = [dict ysf_jsonInteger:YSFApiKeyLocalCmd];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.evaluationData = [dict ysf_jsonDict:YSFApiKeyEvaluationData];
    instance.inviteText = [dict ysf_jsonString:YSFApiKeyEvaluationInviteMsg];
    instance.thanksText = [dict ysf_jsonString:YSFApiKeyEvaluationThanksMsg];
    instance.evaluationTimes = [dict ysf_jsonInteger:YSFApiKeyEvaluationTimes];
    instance.evaluationResult = [dict ysf_jsonString:YSFApiKeyEvaluationResult];
    instance.inviteStatus = [dict ysf_jsonBool:YSFApiKeyEvaluationInviteStatus];
    return instance;
}

@end

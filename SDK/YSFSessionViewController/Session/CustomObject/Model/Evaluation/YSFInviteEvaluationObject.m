#import "YSFInviteEvaluationObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFInviteEvaluationObject

- (NSString *)thumbText {
    return @"感谢您的咨询，请对我们的服务作出评价";
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeySessionId] = @(_sessionId);
    dict[YSFApiKeyEvaluationData] = [_evaluationData ysf_toUTF8String];
    dict[YSFApiKeyEvaluationInviteMsg] = _inviteText;
    dict[YSFApiKeyEvaluationThanksMsg] = _thanksText;
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFInviteEvaluationObject *instance = [[YSFInviteEvaluationObject alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.evaluationData = [dict ysf_jsonDict:YSFApiKeyEvaluationData];
    instance.inviteText = [dict ysf_jsonString:YSFApiKeyEvaluationInviteMsg];
    instance.thanksText = [dict ysf_jsonString:YSFApiKeyEvaluationThanksMsg];
    return instance;
}

@end

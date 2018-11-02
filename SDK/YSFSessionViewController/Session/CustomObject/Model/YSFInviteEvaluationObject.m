#import "YSFInviteEvaluationObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFInviteEvaluationObject

- (NSString *)thumbText
{
    return @"感谢您的咨询，请对我们的服务作出评价";
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeySessionId]    = @(_sessionId);
    dict[YSFApiKeyEvaluationData] = _evaluationDict;    
    dict[YSFApiKeyEvaluationMessageInvite] = _evaluationMessageInvite;
    dict[YSFApiKeyEvaluationMessageThanks] = _evaluationMessageThanks;
    dict[YSFApiEvaluationAutoPopup] = @(_evaluationAutoPopup);

    return dict;
}

+ (YSFInviteEvaluationObject *)objectByDict:(NSDictionary *)dict
{
    YSFInviteEvaluationObject *instance = [[YSFInviteEvaluationObject alloc] init];
    instance.command                = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.evaluationDict = [dict ysf_jsonDict:YSFApiKeyEvaluationData];
    instance.evaluationMessageInvite = [dict ysf_jsonString:YSFApiKeyEvaluationMessageInvite];
    instance.evaluationMessageThanks = [dict ysf_jsonString:YSFApiKeyEvaluationMessageThanks];
    instance.evaluationAutoPopup = [dict ysf_jsonBool:YSFApiEvaluationAutoPopup];

    return instance;
}

@end

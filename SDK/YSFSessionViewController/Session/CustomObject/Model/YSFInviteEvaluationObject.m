#import "YSFInviteEvaluationObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFInviteEvaluationObject
- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeySessionId]    = @(_sessionId);
    dict[YSFApiKeyEvaluationData] = _evaluationDict;    
    dict[YSFApiKeyEvaluationMessageInvite] = _evaluationMessageInvite;
    dict[YSFApiKeyEvaluationMessageThanks] = _evaluationMessageThanks;
    
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

    return instance;
}

@end

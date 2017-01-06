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
    
    return dict;
}

+ (YSFInviteEvaluationObject *)objectByDict:(NSDictionary *)dict
{
    YSFInviteEvaluationObject *instance = [[YSFInviteEvaluationObject alloc] init];
    instance.command                = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.evaluationDict = [dict ysf_jsonDict:YSFApiKeyEvaluationData];

    return instance;
}

@end

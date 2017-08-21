#import "YSFEvaluationNotification.h"
#import "QYSDK_Private.h"

@implementation YSFEvaluationNotification

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFEvaluationNotification * response = [YSFEvaluationNotification new];
    response.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];

    return response;
}

@end

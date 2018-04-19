#import "YSFEvaluationNotification.h"
#import "QYSDK_Private.h"

@implementation YSFEvaluationNotification

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFEvaluationNotification * response = [YSFEvaluationNotification new];
    response.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    response.evaluationAutoPopup = [dict ysf_jsonBool:YSFApiEvaluationAutoPopup];

    return response;
}

@end

#import "YSFEvaluationNotification.h"
#import "QYSDK_Private.h"

@implementation YSFEvaluationNotification

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFEvaluationNotification *response = [[YSFEvaluationNotification alloc] init];
    response.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    response.autoPopup = [dict ysf_jsonBool:YSFApiKeyEvaluationAutoPopup];
    response.evaluationTimes = [dict ysf_jsonInteger:YSFApiKeyEvaluationTimes];
    return response;
}

@end

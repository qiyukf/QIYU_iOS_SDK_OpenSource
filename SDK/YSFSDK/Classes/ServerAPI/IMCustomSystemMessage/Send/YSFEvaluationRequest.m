#import "YSFEvaluationRequest.h"
#import "NSArray+YSF.h"

@implementation YSFEvaluationRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *infos = [NSMutableDictionary dictionary];
    if (_sessionId) {
        NSDictionary *params =  @{
                                  YSFApiKeyCmd          :      @(YSFCommandEvaluationRequest),
                                  YSFApiKeyEvaluation   :      @(_score),
                                  YSFApiKeyRemarks      :      YSFStrParam(_remarks),
                                  YSFApiKeyFromType     :       YSFApiValueIOS,
                                  YSFApiKeySessionId    :      @(_sessionId),
                                  YSFApiKeyTagIds       :      YSFStrParam([_tagIds ysf_toUTF8String])
                                  };
        
        [infos setDictionary:params];
    }
    
    return infos;
}

@end

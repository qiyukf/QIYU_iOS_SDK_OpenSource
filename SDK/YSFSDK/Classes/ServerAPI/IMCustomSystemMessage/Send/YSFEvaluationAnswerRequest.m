#import "YSFEvaluationAnswerRequest.h"


@implementation YSFEvaluationAnswerRequest

- (NSDictionary *)toDict
{
    NSDictionary *infos = @{
                                  YSFApiKeyCmd          :      @(YSFCommandEvaluationAnswer),
                                  YSFApiKeyEvaluation   :      @(_evaluation),
                                  YSFApiKeyMsgIdClient  :      YSFStrParam(_msgidClient),
                                  };
        
    
    return infos;
}

@end

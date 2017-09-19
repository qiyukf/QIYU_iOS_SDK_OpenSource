#import "YSFBotQueryRequest.h"
#import "QYSDK_Private.h"


@implementation YSFQueryOrderListRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandBotQueryRequest),
                              YSFApiKeyTarget   :   YSFStrParam(_target),
                              YSFApiKeyParams   :   YSFStrParam(_params),
                              YSFApiKeyContent   :  YSFStrParam(_content),
                              };
        
    
    return params;
}

@end

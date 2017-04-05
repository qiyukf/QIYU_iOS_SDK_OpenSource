#import "YSFQueryOrderListRequest.h"
#import "QYSDK_Private.h"


@implementation YSFQueryOrderListRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandQueryOrdersRequest),
                              YSFApiKeyTarget   :   YSFStrParam(_target),
                              YSFApiKeyParams   :   YSFStrParam(_params),
                              YSFApiKeyContent   :  YSFStrParam(_content),
                              };
        
    
    return params;
}

@end

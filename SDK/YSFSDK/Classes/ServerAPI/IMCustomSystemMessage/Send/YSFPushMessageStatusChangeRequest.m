#import "YSFPushMessageStatusChangeRequest.h"
#import "QYSDK_Private.h"


@implementation YSFPushMessageStatusChangeRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandPushMessageStatusChangeRequest),
                              YSFApiKeyMessageSessionId  :   @(_msgSessionId),
                              YSFApiKeyStatus   :   @(_status),
                              };
        
    
    return params;
}

@end

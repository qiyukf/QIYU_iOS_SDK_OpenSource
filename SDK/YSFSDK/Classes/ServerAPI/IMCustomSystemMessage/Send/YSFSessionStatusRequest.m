#import "YSFSessionStatusRequest.h"
#import "QYSDK_Private.h"


@implementation YSFSessionStatusRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandSessionStatusRequest),
                              YSFApiKeyDeviceId   :   YSFStrParam([[QYSDK sharedSDK] deviceId]),
                              };
        
    
    return params;
}

@end

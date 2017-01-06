#import "YSFPushMessageRequest.h"
#import "QYSDK_Private.h"


@implementation YSFPushMessageRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandPushMessageRequest),
                              YSFApiKeyDeviceId   :   YSFStrParam([[QYSDK sharedSDK] deviceId]),
                              YSFApiKeyMessageId  :   YSFStrParam(_messageId),
                              };
        
    
    return params;
}

@end

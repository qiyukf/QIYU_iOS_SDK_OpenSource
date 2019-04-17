#import "YSFSendInputtingMessageRequest.h"


@implementation YSFSendInputtingMessageRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandInputtingSend),
                              YSFApiKeySessionId   :   @(_sessionId),
                              YSFApiKeyContent   :   YSFStrParam(_content),
                              YSFApiKeyEndTime   :  @(_endTime),
                              YSFApiKeySendingRate   :  @(_sendingRate),
                              };
    
    return params;
}

@end

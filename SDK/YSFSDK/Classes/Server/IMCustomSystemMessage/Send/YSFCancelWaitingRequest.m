#import "YSFCancelWaitingRequest.h"


@implementation YSFCancelWaitingRequest

- (NSDictionary *)toDict
{
    NSDictionary *infos = @{
                                  YSFApiKeyCmd          :      @(YSFCommandCancelWaiting),
                                  YSFApiKeySessionId   :      @(_sessionId),
                                  };
        
    
    return infos;
}

@end

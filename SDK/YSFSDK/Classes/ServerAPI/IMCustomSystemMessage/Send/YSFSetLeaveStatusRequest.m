#import "YSFSetLeaveStatusRequest.h"
#import "QYSDK_Private.h"

@implementation YSFSetLeaveStatusRequest

- (NSDictionary *)toDict
{
    return  @{
                                    YSFApiKeyCmd          :      @(YSFCommandSetLeaveStatusRequest),
                                    YSFApiKeyDeviceId   :   YSFStrParam([[QYSDK sharedSDK] deviceId]),
                             };
}

@end

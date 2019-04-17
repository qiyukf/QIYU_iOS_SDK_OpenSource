#import "YSFSetUserInfoRequest.h"
#import "QYSDK_Private.h"

@implementation YSFSetInfoRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *infos = [NSMutableDictionary dictionary];
    NSDictionary *params =  @{
                                    YSFApiKeyCmd          :      @(YSFCommandSetUserInfoRequest),
                                    YSFApiKeyForeignId       :      YSFStrParam(_userInfo.userId),
                                    YSFApiKeyUserInfo     :      YSFStrParam(_userInfo.data),
                                    YSFApiKeyAuthToken     :      YSFStrParam(_authToken),
                             };
    
    [infos setDictionary:params];
    
    return infos;
}

@end

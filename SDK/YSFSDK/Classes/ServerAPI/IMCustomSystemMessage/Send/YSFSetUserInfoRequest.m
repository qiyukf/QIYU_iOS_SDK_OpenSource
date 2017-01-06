#import "YSFSetUserInfoRequest.h"
#import "QYSDK_Private.h"

@implementation YSFSetInfoRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *infos = [NSMutableDictionary dictionary];
    NSDictionary *params =  @{
                                    YSFApiKeyCmd          :      @(YSFCommandSetUserInfoRequest),
                                    YSFApiKeyForeignid       :      YSFStrParam(_userInfo.userId),
                                    YSFApiKeyUserInfo     :      YSFStrParam(_userInfo.data),
                             };
    
    [infos setDictionary:params];
    
    return infos;
}

@end

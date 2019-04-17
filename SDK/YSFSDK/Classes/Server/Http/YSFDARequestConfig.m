

#import "YSFDARequestConfig.h"
#import "YSFAccountInfo.h"
#import "NSDictionary+YSFJson.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"
#import "NSArray+YSF.h"

@implementation YSFDARequestConfig

- (NSString *)apiPath
{
    NSString *apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
    apiAddress = [apiAddress ysf_StringByAppendingApiPath:@"/webapi/user/da/config?ak=%@"];
    NSString *urlString = [NSString stringWithFormat:apiAddress, [[QYSDK sharedSDK] appKey]];
    return urlString;
}

- (NSDictionary *)params
{
    return nil;
}

- (id)dataByJson:(NSDictionary *)json
           error:(NSError *__autoreleasing *)error
{
    BOOL track = [[json ysf_jsonDict:YSFApiKeyResult] ysf_jsonBool:YSFApiKeyTrack];
    self.track = track;
    
    return self;
}


@end

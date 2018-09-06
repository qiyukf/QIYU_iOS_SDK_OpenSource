#import "YSFUploadLog.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFUploadLog

- (NSString *)apiPath
{
    NSString *urlString = [_apiAddress ysf_StringByAppendingApiPath:@"/swallow/log"];
    return urlString;
}

- (NSDictionary *)params
{
    NSString *sign = [NSString stringWithFormat:@"ysfios3.5.0%@%@%lldqykf", _type, [[YSF_NIMSDK sharedSDK] appKey], _time];
    sign = [sign ysf_md5];
    return @{
             
             YSFApiKeyTerminal :           @"ios",
             YSFApiKeyVersion :            _version,
             YSFApiKeyPlatform :           [[UIDevice currentDevice] systemVersion],
             YSFApiKeyType :               _type,
             YSFApiKeyAppKey :             [[YSF_NIMSDK sharedSDK] appKey],
             YSFApiKeyClientId :           [[[YSF_NIMSDK sharedSDK] loginManager] currentAccount],
             YSFApiKeyLevel :              @"TRACE",
             YSFApiKeyMessage :            _message,
             YSFApiKeyTimestamp :          @(_time),
             YSFApiKeySign :          sign,
            };
}

- (id)dataByJson:(NSDictionary *)json
           error:(NSError *__autoreleasing *)error
{
    return nil;
}


@end

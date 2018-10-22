#import "YSFUploadLog.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFServerSetting.h"

@implementation YSFUploadLog

- (NSString *)apiPath {
    NSString *apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
    NSString *urlString = [apiAddress ysf_StringByAppendingApiPath:@"/swallow/log"];
    return urlString;
}

- (NSDictionary *)params {
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    NSString *typeString = nil;
    if (YSFUploadLogTypeInvite == self.type) {
        typeString = @"invite";
    } else if (YSFUploadLogTypeSDKInitFail == self.type) {
        typeString = @"network";
    } else if (YSFUploadLogTypeRequestStaffFail == self.type) {
        typeString = @"network";
    }
    NSString *sign = [NSString stringWithFormat:@"ysfios%@%@%@%@qykf", YSFStrParam(_version), YSFStrParam(typeString), [[YSF_NIMSDK sharedSDK] appKey], timeStamp];
    sign = [sign ysf_md5];
    
    return @{
             YSFApiKeyTerminal :    @"ios",
             YSFApiKeyVersion :     YSFStrParam(_version),
             YSFApiKeyPlatform :    [[UIDevice currentDevice] systemVersion],
             YSFApiKeyType :        YSFStrParam(typeString),
             YSFApiKeyAppKey :      [[YSF_NIMSDK sharedSDK] appKey],
             YSFApiKeyClientId :    [[[YSF_NIMSDK sharedSDK] loginManager] currentAccount],
             YSFApiKeyLevel :       @"TRACE",
             YSFApiKeyMessage :     YSFStrParam(_logString),
             YSFApiKeyTimestamp :   timeStamp,
             YSFApiKeySign :        sign,
            };
}

- (id)dataByJson:(NSDictionary *)json
           error:(NSError *__autoreleasing *)error
{
    return nil;
}


@end

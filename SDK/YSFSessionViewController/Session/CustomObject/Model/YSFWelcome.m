#import "YSFWelcome.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFWelcome

- (NSString *)thumbText
{
    NSString *text = [NSString stringWithFormat:@"[%@]", _welcome];
    
    return text;
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeyUserId]       = YSFStrParam(_userId);
    dict[YSFApiKeyDeviceId]     = YSFStrParam(_deviceId);
    dict[YSFApiKeySessionId]    = @(_sessionId);
    dict[YSFApiKeyWelcome]      = YSFStrParam(_welcome);
    
    return dict;
}

+ (YSFWelcome *)objectByDict:(NSDictionary *)dict
{
    YSFWelcome *instance = [[YSFWelcome alloc] init];
    instance.command              = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.userId               = [dict ysf_jsonString:YSFApiKeyUserId];
    instance.deviceId             = [dict ysf_jsonString:YSFApiKeyDeviceId];
    instance.sessionId            = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.welcome              = [dict ysf_jsonString:YSFApiKeyWelcome];
    return instance;
}

@end

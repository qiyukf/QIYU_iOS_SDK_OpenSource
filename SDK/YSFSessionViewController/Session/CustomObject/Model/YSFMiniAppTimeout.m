#import "YSFMiniAppTimeout.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFMiniAppTimeout

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFMiniAppTimeout *instance = [[YSFMiniAppTimeout alloc] init];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.msgIdClient = [dict ysf_jsonString:YSFApiKeyMsgIdClient2];
    NSRange range = [instance.msgIdClient rangeOfString:@"#"];
    if (range.location != NSNotFound && range.location < instance.msgIdClient.length - 1)
    {
        instance.msgIdClient = [instance.msgIdClient substringFromIndex:range.location + 1];
    }
    instance.info = [dict ysf_jsonString:YSFApiKeyInfo];
    
    return instance;
}

@end

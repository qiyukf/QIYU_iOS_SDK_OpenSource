#import "YSFTrashWords.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFTrashWords

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFTrashWords *instance = [[YSFTrashWords alloc] init];
    instance.msgIdClient = [dict ysf_jsonString:YSFApiKeyMsgIdClient2];
    NSRange range = [instance.msgIdClient rangeOfString:@"#"];
    if (range.location != NSNotFound && range.location < instance.msgIdClient.length - 1)
    {
        instance.sessionId = [[instance.msgIdClient substringToIndex:range.location] longLongValue];
        instance.msgIdClient = [instance.msgIdClient substringFromIndex:range.location + 1];
    }
    instance.trashWords = [dict ysf_jsonArray:YSFApiKeyTrashWords];
    if (!instance.trashWords) {
        instance.trashWords = [NSArray new];
    }
    instance.auditResultType = [dict ysf_jsonInteger:YSFApiKeyAuditResult];
    
    return instance;
}

@end

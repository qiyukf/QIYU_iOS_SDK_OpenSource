#import "YSFNotification.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFNotification

- (NSString *)thumbText
{
    NSString *text = [NSString stringWithFormat:@"[%@]", _message];
    
    return text;
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeyLocalCmd]     = @(_localCommand);
    dict[YSFApiKeyMessage]      = YSFStrParam(_message);
    
    return dict;
}

+ (YSFNotification *)objectByDict:(NSDictionary *)dict
{
    YSFNotification *instance = [[YSFNotification alloc] init];
    instance.command              = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.localCommand         = [dict ysf_jsonInteger:YSFApiKeyLocalCmd];
    instance.message              = [dict ysf_jsonString:YSFApiKeyMessage];
    return instance;
}

@end

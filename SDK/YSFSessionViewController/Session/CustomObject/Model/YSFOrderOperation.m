#import "YSFOrderOperation.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFOrderOperation

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyTarget]            = YSFStrParam(_target);
    dict[YSFApiKeyParams]            = YSFStrParam(_params);
    dict[YSFApiKeyTemplate]  = _template;
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFOrderOperation *instance = [[YSFOrderOperation alloc] init];
    instance.command           = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.target            = [dict ysf_jsonString:YSFApiKeyTarget];
    instance.params            = [dict ysf_jsonString:YSFApiKeyParams];
    instance.template           = [dict ysf_jsonDict:YSFApiKeyTemplate];

    return instance;
}

@end

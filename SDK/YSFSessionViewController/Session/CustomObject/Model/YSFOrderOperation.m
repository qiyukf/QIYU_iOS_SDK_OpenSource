#import "YSFOrderOperation.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFOrderOperation

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeyTarget] = YSFStrParam(_target);
    dict[YSFApiKeyParams] = YSFStrParam(_params);
    if (_label.length) {
        dict[YSFApiKeyLabel] = YSFStrParam(_label);
    }
    if (_type.length) {
        dict[YSFApiKeyType] = YSFStrParam(_type);
    }
    dict[YSFApiKeyTemplate]  = _templateInfo;
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFOrderOperation *instance = [[YSFOrderOperation alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.target = [dict ysf_jsonString:YSFApiKeyTarget];
    instance.params = [dict ysf_jsonString:YSFApiKeyParams];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.type = [dict ysf_jsonString:YSFApiKeyType];
    instance.templateInfo = [dict ysf_jsonDict:YSFApiKeyTemplate];

    return instance;
}

@end

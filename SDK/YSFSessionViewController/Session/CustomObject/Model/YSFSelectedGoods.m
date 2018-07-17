#import "YSFSelectedGoods.h"
#import "NSDictionary+YSFJson.h"
#import "YSFSelectedGoodsContentConfig.h"

@implementation YSFSelectedCommodityInfo

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFSelectedGoodsContentConfig *)contentConfig
{
    return [YSFSelectedGoodsContentConfig new];
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyTarget]            = YSFStrParam(_target);
    dict[YSFApiKeyParams]            = YSFStrParam(_params);
    NSDictionary *template = [_goods encodeAttachment];
    dict[YSFApiKeyTemplate]  = template;
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFSelectedCommodityInfo *instance = [[YSFSelectedCommodityInfo alloc] init];
    instance.command           = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.target            = [dict ysf_jsonString:YSFApiKeyTarget];
    instance.params            = [dict ysf_jsonString:YSFApiKeyParams];
    NSDictionary *template           = [dict ysf_jsonDict:YSFApiKeyTemplate];
    instance.goods = [QYSelectedCommodityInfo objectByDict:template];
    
    return instance;
}

@end

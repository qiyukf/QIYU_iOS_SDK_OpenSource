#import "YSFOrderList.h"
#import "NSDictionary+YSFJson.h"
#import "YSFOrderListContentConfig.h"



@implementation QYSelectedCommodityInfo

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyId]      = @"qiyu_template_goods";
    dict[YSFApiKeyPStatus]      = YSFStrParam(_p_status);
    dict[YSFApiKeyPImg]         = YSFStrParam(_p_img);
    dict[YSFApiKeyPName]        = YSFStrParam(_p_name);
    dict[YSFApiKeyPStock]        = YSFStrParam(_p_stock);
    dict[YSFApiKeyPPrice]       = YSFStrParam(_p_price);
    dict[YSFApiKeyPCount]       = YSFStrParam(_p_count);
    dict[YSFApiKeyParams]       = YSFStrParam(_params);
    dict[YSFApiKeyTarget]       = YSFStrParam(_target);
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    QYSelectedCommodityInfo *instance = [QYSelectedCommodityInfo new];
    instance.p_status = [dict ysf_jsonString:YSFApiKeyPStatus];
    instance.p_img = [dict ysf_jsonString:YSFApiKeyPImg];
    instance.p_name = [dict ysf_jsonString:YSFApiKeyPName];
    instance.p_stock = [dict ysf_jsonString:YSFApiKeyPStock];
    instance.p_price = [dict ysf_jsonString:YSFApiKeyPPrice];
    instance.p_count = [dict ysf_jsonString:YSFApiKeyPCount];
    instance.params = [dict ysf_jsonString:YSFApiKeyParams];
    instance.target = [dict ysf_jsonString:YSFApiKeyTarget];
    
    return instance;
}

@end


@implementation YSFShop

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFShop *instance = [YSFShop new];
    instance.s_status = [dict ysf_jsonString:YSFApiKeySStatus];
    instance.s_name = [dict ysf_jsonString:YSFApiKeySName];

    NSArray *goodsArray = [dict ysf_jsonArray:YSFApiKeyGoods];
    NSMutableArray *mutableGoods = [NSMutableArray new];
    [goodsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        QYSelectedCommodityInfo *shop = [QYSelectedCommodityInfo objectByDict:dict];
        [mutableGoods addObject:shop];
    }];
    instance.goods = mutableGoods;
    
    return instance;
}

@end


@implementation YSFOrderList

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFOrderListContentConfig *)contentConfig
{
    return [YSFOrderListContentConfig new];
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFOrderList *instance = [YSFOrderList new];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    NSDictionary *actionDict = [dict ysf_jsonDict:YSFApiKeyAction];
    instance.action = [YSFAction objectByDict:actionDict];
    
    NSArray *listArray = [dict ysf_jsonArray:YSFApiKeyList];
    NSMutableArray *mutableShops = [NSMutableArray new];
    [listArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        YSFShop *shop = [YSFShop objectByDict:dict];
        [mutableShops addObject:shop];
    }];
    instance.shops = mutableShops;
    
    return instance;
}

@end

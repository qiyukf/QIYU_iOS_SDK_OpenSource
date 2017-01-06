#import "YSFKFBypassNotification.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFShopInfo.h"


@implementation YSFKFBypassNotification

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFKFBypassNotification *instance = [[YSFKFBypassNotification alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.message = [dict ysf_jsonString:YSFApiKeyMessage];
    instance.iconUrl = dict[YSFApiKeyIconUrl];
    NSString *entries = [dict ysf_jsonString:YSFApiKeyEntries];
    if (entries) {
        instance.entries = [entries ysf_toArray];
    }
    instance.disable = [dict ysf_jsonBool:YSFApiKeyDisable];
    
    NSDictionary *shopInfoDict = [dict ysf_jsonDict:YSFApiKeyShop];
    if (shopInfoDict) {
        instance.shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
    }
    
    return instance;
}


- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyMessage]          = YSFStrParam(_message);
    dict[YSFApiKeyIconUrl]          = YSFStrParam(_iconUrl);
    NSData *arrayData = [NSJSONSerialization dataWithJSONObject:_entries
                                                        options:0
                                                          error:nil];
    if (arrayData)
    {
        dict[YSFApiKeyEntries]  = [[NSString alloc] initWithData:arrayData
                                                           encoding:NSUTF8StringEncoding];
    }
    dict[YSFApiKeyDisable]          = @(_disable);
    dict[YSFApiKeyShop]         = [_shopInfo toDict];

    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    return [self dataByJson:dict];
}
@end

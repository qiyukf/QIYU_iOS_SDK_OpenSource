#import "YSFKFBypassNotification.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFShopInfo.h"
#import "YSFKFBypassContentConfig.h"


@implementation YSFKFBypassNotification

- (NSString *)thumbText
{
    NSString *text = [NSString stringWithFormat:@"[%@:", _message];
    NSInteger index = 0;
    for (NSDictionary *item in _entries) {
        NSString *labelText = item[@"label"] ? : @"";
        if (index != _entries.count - 1) {
            text = [text stringByAppendingFormat:@"%@ / ", labelText];
        }
        else {
            text = [text stringByAppendingFormat:@"%@]", labelText];
        }
        index++;
    }
    
    return text;
}

- (YSFKFBypassContentConfig *)contentConfig
{
    return [YSFKFBypassContentConfig new];
}

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

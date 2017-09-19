
#import "YSFFlightDetail.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "YSFCoreText.h"

@implementation YSFFlightInfoField

+ (YSFFlightInfoField *)objectByDict:(NSDictionary *)dict
{
    YSFFlightInfoField *instance = [[YSFFlightInfoField alloc] init];
    instance.name = [dict ysf_jsonString:YSFApiKeyName];
    instance.type            = [dict ysf_jsonString:YSFApiKeyType];
    instance.value            = [dict ysf_jsonString:YSFApiKeyValue];
    instance.color            = [dict ysf_jsonString:YSFApiKeyColor];
    instance.align            = [dict ysf_jsonString:YSFApiKeyAlign];
    instance.flag            = [dict ysf_jsonInteger:YSFApiKeyFlag];
    
    return instance;
}

@end

@implementation YSFFlightItem
@end

@implementation YSFFlightThumbnail

+ (YSFFlightThumbnail *)objectByDict:(NSDictionary *)dict
{
    YSFFlightThumbnail *instance = [[YSFFlightThumbnail alloc] init];

    instance.action = [YSFAction objectByDict:[dict ysf_jsonDict:YSFApiKeyAction]];
    instance.fields = [NSMutableArray new];

    NSArray *listArray      = [dict ysf_jsonArray:YSFApiKeyList];
    for (NSArray *filedsList in listArray) {
        NSMutableArray *row = [NSMutableArray new];
        for (NSDictionary *filed in filedsList) {
            YSFFlightInfoField *fieldInfoField = [YSFFlightInfoField objectByDict:filed];
            [row addObject:fieldInfoField];
        }
        [instance.fields addObject:row];
    }

    return instance;
}

@end

@implementation YSFFlightDetail

+ (YSFFlightDetail *)objectByDict:(NSDictionary *)dict
{
    YSFFlightDetail *instance = [[YSFFlightDetail alloc] init];
    instance.label            = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.flightDetailItems = [NSMutableArray new];
    NSArray *listArray      = [dict ysf_jsonArray:YSFApiKeyList];
    for (NSArray *array in listArray) {
        NSMutableArray *group = [NSMutableArray new];
        for (NSDictionary *dict in array) {
            YSFFlightItem *item = [YSFFlightItem new];
            item.fields = [NSMutableArray new];
            NSMutableArray *row = [NSMutableArray new];
            [row addObject:[YSFFlightInfoField objectByDict:[dict ysf_jsonDict:YSFApiKeyLeft]]];
            [row addObject:[YSFFlightInfoField objectByDict:[dict ysf_jsonDict:YSFApiKeyRight]]];
            [item.fields addObject:row];
            [group addObject:item];
        }

        [instance.flightDetailItems addObject:group];
    }
    
    return instance;
}

@end


@implementation YSFFlightThumbnailAndDetail


+(YSFFlightThumbnailAndDetail *)objectByDict:(NSDictionary *)dict
{
    YSFFlightThumbnailAndDetail *instance = [[YSFFlightThumbnailAndDetail alloc] init];
    instance.thumbnail = [YSFFlightThumbnail objectByDict:[dict ysf_jsonDict:YSFApiKeyThumbnail]];
    instance.detail = [YSFFlightDetail objectByDict:[dict ysf_jsonDict:YSFApiKeyDetail]];

    return instance;
}

@end

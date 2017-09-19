
#import "YSFFlightList.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "YSFCoreText.h"







@implementation YSFFlightList


+(YSFFlightList *)objectByDict:(NSDictionary *)dict
{
    YSFFlightList *instance = [[YSFFlightList alloc] init];
    instance.label          = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.action         = [YSFAction objectByDict:[dict ysf_jsonDict:YSFApiKeyAction]];
    NSArray *listArray      = [dict ysf_jsonArray:YSFApiKeyList];
    instance.fieldItems = [NSMutableArray new];
    
    for (NSDictionary *dict in listArray) {
        YSFFlightItem *flightItem = [YSFFlightItem new];
        YSFAction *action = [YSFAction objectByDict:[dict ysf_jsonDict:YSFApiKeyAction]];
        flightItem.action = action;
        flightItem.fields = [NSMutableArray new];
        NSArray *filedsList = [dict ysf_jsonArray:YSFApiKeyList];

        for (NSArray *filedArray in filedsList) {
            NSMutableArray *line = [NSMutableArray new];
            for (NSDictionary *filed in filedArray) {
                YSFFlightInfoField *fieldInfoField = [YSFFlightInfoField objectByDict:filed];
                [line addObject:fieldInfoField];
            }
            [flightItem.fields addObject:line];
        }
        
        [instance.fieldItems addObject:flightItem];
    }

    return instance;
}

+ (YSFFlightList *)objectByFlightThumbnail:(YSFFlightThumbnail *)flightThumbnail
{
    YSFFlightList *instance = [[YSFFlightList alloc] init];
    instance.action         = flightThumbnail.action;
    instance.fieldItems = [NSMutableArray new];
    
    YSFFlightItem *flightItem = [YSFFlightItem new];
    flightItem.fields = [NSMutableArray new];
    flightItem.fields = flightThumbnail.fields;
    
    [instance.fieldItems addObject:flightItem];
    
    return instance;
}

+ (YSFFlightList *)objectByFlightDetail:(YSFFlightDetail *)flightDetail
{
    YSFFlightList *instance = [[YSFFlightList alloc] init];
    instance.fieldItems = [NSMutableArray new];
    
    YSFFlightItem *flightItem = [YSFFlightItem new];
    flightItem.fields = [NSMutableArray new];
    flightItem.fields = flightDetail.flightDetailItems;
    
    [instance.fieldItems addObject:flightItem];
    
    return instance;
}
@end

#import "YSFStaticUnion.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFLinkItem

@end

@interface YSFStaticUnion()

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFStaticUnion

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFStaticUnion *staticUnion = [YSFStaticUnion new];
    staticUnion.imageUrlStringArray = [NSMutableArray new];

    NSMutableArray<YSFLinkItem *> *tmpLinkItems = [NSMutableArray<YSFLinkItem *> new];
    NSArray *items = [dict ysf_jsonArray:YSFApiKeyUnions];
    for (NSDictionary *dict in items) {
        YSFLinkItem *item = [YSFLinkItem new];
        NSString *type = [dict ysf_jsonString:YSFApiKeyType];
        item.type = type;
        NSDictionary *detail = [dict ysf_jsonDict:YSFApiKeyDetail];
        if ([type isEqualToString:@"text"]) {
            item.label = [detail ysf_jsonString:YSFApiKeyLabel];
        }
        else if ([type isEqualToString:@"image"])
        {
            item.imageUrl = [detail ysf_jsonString:YSFApiKeyUrl];
            [staticUnion.imageUrlStringArray addObject:item.imageUrl];
        }
        else if ([type isEqualToString:@"link"])
        {
            item.label = [detail ysf_jsonString:YSFApiKeyLabel];
            item.target = [detail ysf_jsonString:YSFApiKeyTarget];
            item.params = [detail ysf_jsonString:YSFApiKeyParams];
            item.linkType = [detail ysf_jsonString:YSFApiKeyType];
        }
        [tmpLinkItems addObject:item];
    }
    staticUnion.linkItems = tmpLinkItems;
    
    return staticUnion;
}

@end

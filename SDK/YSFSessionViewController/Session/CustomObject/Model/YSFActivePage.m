#import "YSFActivePage.h"
#import "NSDictionary+YSFJson.h"
#import "YSFActivePageContentConfig.h"

@implementation YSFActivePage

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFActivePageContentConfig *)contentConfig
{
    return [YSFActivePageContentConfig new];
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFActivePage *activePage = [YSFActivePage new];
    activePage.img = [dict ysf_jsonString:YSFApiKeyImg];
    activePage.content = [dict ysf_jsonString:YSFApiKeyContent];
    activePage.action = [YSFAction objectByDict:[dict ysf_jsonDict:YSFApiKeyAction]];
    
    return activePage;
}

@end

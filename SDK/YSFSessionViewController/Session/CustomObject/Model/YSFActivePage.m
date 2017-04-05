#import "YSFActivePage.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFActivePage

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFActivePage *activePage = [YSFActivePage new];
    activePage.img = [dict ysf_jsonString:YSFApiKeyImg];
    activePage.content = [dict ysf_jsonString:YSFApiKeyContent];
    activePage.action = [YSFAction objectByDict:[dict ysf_jsonDict:YSFApiKeyAction]];
    
    return activePage;
}

@end

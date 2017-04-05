#import "YSFBotText.h"
#import "NSDictionary+YSFJson.h"



@implementation YSFBotText

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFBotText *instance = [YSFBotText new];
    instance.text = [dict ysf_jsonString:YSFApiKeyTemplate];
    
    return instance;
}

@end

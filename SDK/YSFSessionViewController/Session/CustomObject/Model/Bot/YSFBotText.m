#import "YSFBotText.h"
#import "NSDictionary+YSFJson.h"



@implementation YSFBotText

- (NSString *)thumbText
{
    return @"[查询消息]";
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFBotText *instance = [YSFBotText new];
    instance.text = [dict ysf_jsonString:YSFApiKeyTemplate];
    
    return instance;
}

@end

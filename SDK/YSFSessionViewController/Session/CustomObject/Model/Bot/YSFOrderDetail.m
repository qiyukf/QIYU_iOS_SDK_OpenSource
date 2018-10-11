#import "YSFOrderDetail.h"
#import "NSDictionary+YSFJson.h"
#import "YSFOrderDetailContentConfig.h"



@implementation YSFOrderDetail

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFOrderDetailContentConfig *)contentConfig
{
    return [YSFOrderDetailContentConfig new];
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFOrderDetail *instance = [YSFOrderDetail new];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.status = [dict ysf_jsonString:YSFApiKeyStatus];
    instance.userName = [dict ysf_jsonString:YSFApiKeyUserName];
    instance.address = [dict ysf_jsonString:YSFApiKeyAddress];
    instance.orderNo = [dict ysf_jsonString:YSFApiKeyOrderNo];
    instance.date = [[dict ysf_jsonArray:YSFApiKeyDate] objectAtIndex:0];
    
    return instance;
}

@end

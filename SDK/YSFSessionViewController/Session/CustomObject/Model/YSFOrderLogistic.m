#import "YSFOrderLogistic.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFOrderLogisticNode

@end



@implementation YSFOrderLogistic

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFOrderLogistic *instance = [YSFOrderLogistic new];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    NSDictionary *actionDict = [dict ysf_jsonDict:YSFApiKeyAction];
    instance.action = [YSFAction objectByDict:actionDict];
    instance.title = [[dict ysf_jsonDict:YSFApiKeyTitle] ysf_jsonString:YSFApiKeyLabel];
    
    NSArray *list = [dict ysf_jsonArray:YSFApiKeyList];
    NSMutableArray *mutableLogistic = [[NSMutableArray alloc] init];
    [list enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        YSFOrderLogisticNode *node = [YSFOrderLogisticNode new];
        node.logistic = [dict ysf_jsonString:YSFApiKeyLogistic];
        node.timestamp = [dict ysf_jsonString:YSFApiKeyTimestamp];
        [mutableLogistic addObject:node];
    }];
    instance.logistic = mutableLogistic;
    
    return instance;
}

@end

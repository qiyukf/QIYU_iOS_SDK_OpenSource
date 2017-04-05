#import "YSFActionList.h"
#import "NSDictionary+YSFJson.h"
#import "YSFAction.h"


@implementation YSFActionList

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFActionList *instance = [YSFActionList new];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    NSArray *list = [dict ysf_jsonArray:YSFApiKeyList];
    NSMutableArray *mutableList = [[NSMutableArray alloc] init];
    [list enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableList addObject:[YSFAction objectByDict:dict]];
        
    }];
    instance.actionArray = mutableList;
    
    return instance;
}

@end

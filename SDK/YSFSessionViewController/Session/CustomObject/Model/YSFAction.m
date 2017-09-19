#import "YSFAction.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"


@implementation YSFAction

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFAction *action = [YSFAction new];
    action.style = [dict ysf_jsonString:YSFApiKeyStyle];
    action.type = [dict ysf_jsonString:YSFApiKeyType];
    action.url = [dict ysf_jsonString:YSFApiKeyUrl];
    action.params = [dict ysf_jsonString:YSFApiKeyParams];
    action.target = [dict ysf_jsonString:YSFApiKeyTarget];
    if (!action.target) {
        action.target = action.url;
    }
    action.title = [dict ysf_jsonString:YSFApiKeyTitle];
    action.validOperation = [dict ysf_jsonString:YSFApiKeyValidOperation];
    NSString *pName = [dict ysf_jsonString:YSFApiKeyPName];
    NSString *label = [dict ysf_jsonString:YSFApiKeyLabel];
    if (action.validOperation.length == 0) {
        action.validOperation = pName;
    }
    if (action.validOperation.length == 0) {
        action.validOperation = label;
    }
    return action;
}

@end

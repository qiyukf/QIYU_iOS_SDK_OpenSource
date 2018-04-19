#import "YSFLongMessage.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFLongMessage

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFLongMessage *instance = [[YSFLongMessage alloc] init];
    instance.msgType = [dict ysf_jsonInteger:YSFApiKeyMsgType];
    instance.msgId = [dict ysf_jsonString:YSFApiKeyMsgId2];
    instance.splitId = [dict ysf_jsonString:YSFApiKeySplitId];
    instance.splitCount = [dict ysf_jsonInteger:YSFApiKeySplitCount];
    instance.splitIndex = [dict ysf_jsonInteger:YSFApiKeySplitIndex];
    instance.splitContent= [dict ysf_jsonString:YSFApiKeySplitContent];

    return instance;
}

@end

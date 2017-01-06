#import "YSFSessionClose.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFSessionClose

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeySessionId]    = @(_sessionId);
    dict[YSFApiKeyCloseType]    = @(_closeType);
    
    return dict;
}

+ (YSFSessionClose *)objectByDict:(NSDictionary *)dict
{
    YSFSessionClose *instance = [[YSFSessionClose alloc] init];
    instance.command              = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.sessionId            = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.closeType            = [dict ysf_jsonInteger:YSFApiKeyCloseType];
    if (instance.closeType == 0) {
        instance.message = @"客服关闭";
    }
    else if (instance.closeType == 1) {
        instance.message = @"用户离开";
    }
    else if (instance.closeType == 2) {
        instance.message = @"系统关闭";
    }
    else if (instance.closeType == 3) {
        instance.message = @"机器人会话结束";
    }
    else if (instance.closeType == 4) {
        instance.message = @"客服无网络连接，系统自动关闭会话";
    }
    else if (instance.closeType == 5) {
        instance.message = @"会话已转接";
    }
    else {
        NSAssert(NO, @"not handled this closeType");
    }
    return instance;
}

@end

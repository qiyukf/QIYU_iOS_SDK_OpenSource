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
        NSString *text = nil;
        NSDictionary *newStaffInfo = [[dict ysf_jsonString:@"newStaffInfo"] ysf_toDict];
        NSString *realname = [newStaffInfo ysf_jsonString:@"realname"];
        NSString *remarks = [dict ysf_jsonString:@"transferRemarks"];
        if (realname && remarks) {
            if ([remarks isEqualToString:@""]) {
                text = [NSString stringWithFormat:@"会话转接至 %@", realname];
            } else {
                text = [NSString stringWithFormat:@"会话转接至 %@\n备注：%@", realname, remarks];
            }
        } else {
            text = @"会话已转接";
        }
        instance.message = text;
    }
    else if (instance.closeType == 6) {
        instance.message = @"已被其他客服接待";     //由于产品未确定，文案是码农自己添加，不做参考，只做备用
    }
    else if (instance.closeType == 7) {
        instance.message = @"访客关闭";         //由于产品未确定，文案是码农自己添加，不做参考，只做备用
    }
    else if (instance.closeType == 8) {
        instance.message = @"会话超时关闭";       //由于产品未确定，文案是码农自己添加，不做参考，只做备用
    }
    else {
        NSAssert(NO, @"not handled this closeType %ld", instance.closeType);
    }
    return instance;
}

@end

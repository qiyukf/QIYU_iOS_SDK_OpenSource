#import "YSFRefundDetail.h"
#import "NSDictionary+YSFJson.h"
#import "YSFRefundDetailContentConfig.h"

@implementation YSFRefundDetail

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFRefundDetailContentConfig *)contentConfig
{
    return [YSFRefundDetailContentConfig new];
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFRefundDetail *refundDetail = [YSFRefundDetail new];
    refundDetail.label = [dict ysf_jsonString:YSFApiKeyLabel];
    NSDictionary *stateDict = [dict ysf_jsonDict:YSFApiKeyState];
    refundDetail.refundStateType = [stateDict ysf_jsonString:YSFApiKeyType];
    refundDetail.refundStateText = [stateDict ysf_jsonString:YSFApiKeyName];
    refundDetail.contentList = [dict ysf_jsonArray:YSFApiKeyList];
    return refundDetail;
}

@end

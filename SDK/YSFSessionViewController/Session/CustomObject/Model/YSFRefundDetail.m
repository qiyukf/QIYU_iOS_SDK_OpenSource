#import "YSFRefundDetail.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFRefundDetail

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

#import "YSFQueryOrderListResponse.h"
#import "QYSDK_Private.h"

@implementation YSFQueryOrderListResponse

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    NSDictionary *template = [dict ysf_jsonDict:YSFApiKeyTemplate];
    YSFQueryOrderListResponse * response = [YSFQueryOrderListResponse new];
    response.orderList = [YSFOrderList objectByDict:template];

    return response;
}

@end

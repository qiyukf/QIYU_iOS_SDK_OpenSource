#import "YSFSessionStatusResponse.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFSessionStatusResponse

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFSessionStatusResponse *instance = [YSFSessionStatusResponse new];
    NSArray *array = [dict ysf_jsonArray:YSFApiKeyResult];
    NSMutableDictionary *sessionStatus = [[NSMutableDictionary alloc] initWithCapacity:array.count];
    for (NSDictionary *sessionInfo in array) {
        NSDictionary *shopInfo = [sessionInfo ysf_jsonDict:YSFApiKeyShop];
        NSString *shopId = [shopInfo ysf_jsonString:YSFApiKeyId];
        NSDictionary *statusDict = [sessionInfo ysf_jsonDict:YSFApiKeySessionStatus];
        NSInteger status = [statusDict ysf_jsonInteger:YSFApiKeyStatus];
        if (shopId) {
            sessionStatus[shopId] = @(status);
        }
    }
    instance.shopSessionStatus = sessionStatus;
    return instance;
}

@end

#import "YSFEvaluationRequest.h"
#import "NSArray+YSF.h"

@interface YSFKaolaTagInfo : NSObject

@property (nonatomic,assign)                long long id;
@property (nonatomic,copy)                NSString *name;

@end

@implementation YSFEvaluationRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *infos = [@{
                              YSFApiKeyCmd          :      @(YSFCommandEvaluationRequest),
                              YSFApiKeyEvaluation   :      @(_score),
                              YSFApiKeyRemarks      :      YSFStrParam(_remarks),
                              YSFApiKeyFromType     :       YSFApiValueIOS,
                              YSFApiKeySessionId    :      @(_sessionId),
                              } mutableCopy];
    
    if (_tagInfos) {
        NSMutableArray *tagInfoArray = [NSMutableArray new];
        for (id tagInfo in _tagInfos) {
            if ([tagInfo isKindOfClass:[YSFKaolaTagInfo class]]) {
                NSDictionary *tagInfoDict =  @{ YSFApiKeyId : @(((YSFKaolaTagInfo *)tagInfo).id),
                                                YSFApiKeyName : YSFStrParam(((YSFKaolaTagInfo *)tagInfo).name),
                                                };
                [tagInfoArray addObject:tagInfoDict];
            } else {
                [tagInfoArray addObject:tagInfo];
            }
        }
        [infos setValue:[tagInfoArray ysf_toUTF8String] forKey:YSFApiKeyTagList];
    }
    
    return infos;
}

@end

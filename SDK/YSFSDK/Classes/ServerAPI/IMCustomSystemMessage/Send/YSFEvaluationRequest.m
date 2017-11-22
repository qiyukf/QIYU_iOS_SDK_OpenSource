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
        for (YSFKaolaTagInfo *tagInfo in _tagInfos) {
            NSDictionary *tagInfoDict =  @{ YSFApiKeyId : @(tagInfo.id),
                                            YSFApiKeyName : YSFStrParam(tagInfo.name),
                                            };
            [tagInfoArray addObject:tagInfoDict];
        }
        [infos setObject:[tagInfoArray ysf_toUTF8String] forKey:YSFApiKeyTagList];
    }
    
    return infos;
}

@end

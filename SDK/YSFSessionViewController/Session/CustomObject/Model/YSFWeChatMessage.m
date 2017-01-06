#import "YSFWeChatMessage.h"

@implementation YSFWeChatMessage



//- (NSString *)encodeAttachment
//{
//    NSString *result = nil;
//    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
//    
//    dict[YSFApiKeyCmd]          = @(_command);
//    dict[YSFApiKeyTipContent]      = YSFStrParam(_tipContent);
//    dict[YSFApiKeyTipResult]      = YSFStrParam(_tipResult);
//    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
//                                                   options:0
//                                                     error:nil];
//    if (data)
//    {
//        result = [[NSString alloc] initWithData:data
//                                       encoding:NSUTF8StringEncoding];
//    }
//    return result;
//}
//
//+ (YSFEvaluationTipObject *)objectByDict:(NSDictionary *)dict
//{
//    YSFEvaluationTipObject *instance = [[YSFEvaluationTipObject alloc] init];
//    instance.command                = [dict ysf_jsonInteger:YSFApiKeyCmd];
//    instance.tipContent             = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipContent]);
//    instance.tipResult             = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipResult]);
//    
//    return instance;
//}



- (NSDictionary *)toDict
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd         :   @(YSFCommandWeChatMessage),
                                       YSFApiKeyPlatform    :   @(2),
                                       YSFApiKeyFrom        :   YSFStrParam(_from),
                                       YSFApiKeyTo          :   YSFStrParam(_to),
                                       YSFApiKeyType        :   YSFStrParam(_type),
                                       YSFApiKeyBody        :   YSFStrParam(_body),
                                       }];
    
    return params;
}

@end

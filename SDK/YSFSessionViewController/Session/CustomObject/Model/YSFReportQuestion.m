#import "YSFReportQuestion.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFReportQuestion

- (NSString *)thumbText {
    NSString *text = [NSString stringWithFormat:@"%@", _question];
    return text;
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd : @(_command),
                                       YSFApiKeyQuestion : YSFStrParam(_question),
                                       YSFApiKeyQuestionId : @(_questionId),
                                       YSFApiKeyQuestionMsgId : YSFStrParam(_messageId),
                                       }];
    return params;
}

+ (YSFReportQuestion *)objectByDict:(NSDictionary *)dict {
    YSFReportQuestion *instance = [[YSFReportQuestion alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.question = [dict ysf_jsonString:YSFApiKeyQuestion];
    instance.questionId = [dict ysf_jsonLongLong:YSFApiKeyQuestionId];
    return instance;
}


@end

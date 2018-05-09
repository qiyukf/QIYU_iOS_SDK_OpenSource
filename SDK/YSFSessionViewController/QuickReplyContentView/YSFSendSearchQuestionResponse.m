

#import "YSFSendSearchQuestionResponse.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFQuickReplyKeyWordAndContent
@end

@implementation YSFSendSearchQuestionResponse

+ (YSFSendSearchQuestionResponse *)dataByJson:(NSDictionary *)dict
{
    YSFSendSearchQuestionResponse *instance     = [[YSFSendSearchQuestionResponse alloc] init];
    instance.sessionId              = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.content                = [dict ysf_jsonString:YSFApiKeyContent];
    NSArray *array = [dict ysf_jsonArray:YSFApiKeyQuestionContents];
    NSMutableArray *contentArray = [NSMutableArray new];
    for (NSDictionary *dict in array) {
        NSString *value = [dict ysf_jsonString:YSFApiKeyValue];
        YSFQuickReplyKeyWordAndContent *content = [YSFQuickReplyKeyWordAndContent new];
        content.content = value;
        [contentArray addObject:content];
    }
    instance.questionContents = contentArray;
    
    return instance;
}
@end



#import "YSFSendSearchQuestionRequest.h"

@interface YSFSendSearchQuestionRequest ()
@property (nonatomic,copy)        NSString *msgType;
@end

@implementation YSFSendSearchQuestionRequest

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyCmd        :   @(YSFCommandSearchQuestiongRequest),
                              YSFApiKeySessionId  :   @(_sessionId),
                              YSFApiKeyMsgType2   :   @"text",
                              YSFApiKeyContent    :   YSFStrParam(_content)
                              };
    
    return params;
}

@end

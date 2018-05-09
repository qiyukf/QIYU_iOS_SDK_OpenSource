#import "YSFSearchQuestionSetting.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"



@interface YSFSearchQuestionSetting()

@property (nonatomic,strong)   NSMutableDictionary *configDict;

@end


@implementation YSFSearchQuestionSetting

+ (instancetype)sharedInstance
{
    static YSFSearchQuestionSetting *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFSearchQuestionSetting alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _switchOpen = YES;
        _sessionId = 0;
        _sendingRate = 1.5;
        _configDict = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)sharedInstance:(NSString *)shopId
{
    if (!shopId) {
        return nil;
    }
    
    YSFSearchQuestionSetting *config = [YSFSearchQuestionSetting sharedInstance].configDict[shopId];
    if (!config) {
        config = [YSFSearchQuestionSetting new];
        [YSFSearchQuestionSetting sharedInstance].configDict[shopId] = config;
    }
    return config;
}

- (void)dataByJson:(NSDictionary *)dict
{
    self.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    self.sendingRate = [dict ysf_jsonDouble:YSFApiKeySendingRate];
    self.switchOpen = [dict ysf_jsonBool:YSFApiKeySwitch];
}

- (void)clear
{
    self.switchOpen = NO;
    self.sessionId = 0;
    self.sendingRate = 0;
}

@end

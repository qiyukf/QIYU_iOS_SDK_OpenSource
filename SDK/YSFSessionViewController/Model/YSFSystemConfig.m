#import "YSFSystemConfig.h"


@implementation YSFSystemConfig

+ (instancetype)sharedInstance
{
    static YSFSystemConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFSystemConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _switchOpen = YES;
        _sendingRate = 1.5;
    }
    return self;
}

- (instancetype)setNewConfig:(NSDictionary *)dict;
{
    NSString *type = [dict ysf_jsonString:YSFApiKeyType];
    if ([type isEqualToString:@"client_input"]) {
        NSDictionary *config = [dict ysf_jsonDict:YSFApiKeyConfig];
        self.switchOpen = [config ysf_jsonBool:YSFApiKeySwitch];
        self.sendingRate = [config ysf_jsonDouble:YSFApiKeySendingRate];
    }
    
    return self;
}


@end

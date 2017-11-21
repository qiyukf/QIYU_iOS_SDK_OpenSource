#import "YSFSystemConfig.h"

@interface YSFSystemConfig()

@property (nonatomic,strong)   NSMutableDictionary *systemConfigDict;

@end


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
        _systemConfigDict = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)sharedInstance:(NSString *)shopId
{
    if (!shopId) {
        return nil;
    }
    
    YSFSystemConfig *systemConfig = [YSFSystemConfig sharedInstance].systemConfigDict[shopId];
    if (!systemConfig) {
        systemConfig = [YSFSystemConfig new];
        [YSFSystemConfig sharedInstance].systemConfigDict[shopId] = systemConfig;
    }
    return systemConfig;
}

- (instancetype)setNewConfig:(NSDictionary *)dict
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

#import "YSFAppSetting.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFAppSetting
+ (instancetype)infoByDict:(NSDictionary *)dict {
    YSFAppSetting *instance = [[YSFAppSetting alloc] init];
    instance.recevierOrSpeaker = [dict ysf_jsonBool:@"recevierOrSpeaker"];
    return instance;
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self isValid]) {
        NSNumber *recevierOrSpeaker = [[NSNumber alloc] initWithBool: _recevierOrSpeaker];
        [dict setValue:recevierOrSpeaker forKey:@"recevierOrSpeaker"];
    } else {
        YSFLogErr(@"invalid app info");
    }
    return dict;
}

+ (instancetype)defaultSetting {
    YSFAppSetting *instance = [[YSFAppSetting alloc] init];
    instance.recevierOrSpeaker = NO;
    return instance;
}

- (BOOL)isValid {
    return YES;
}

@end

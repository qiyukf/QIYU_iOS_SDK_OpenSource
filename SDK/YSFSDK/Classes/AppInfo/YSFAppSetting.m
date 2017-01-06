

#import "YSFAppSetting.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFAppSetting

- (BOOL)isValid
{
    return YES;
}

+ (instancetype)infoByDict:(NSDictionary *)dict
{
    YSFAppSetting *instance        = [[YSFAppSetting alloc] init];
    instance.recevierOrSpeaker = [dict ysf_jsonBool:@"recevierOrSpeaker"];
    return instance;
}

+ (instancetype)defaultSetting
{
    YSFAppSetting *instance        = [[YSFAppSetting alloc] init];
    instance.recevierOrSpeaker = NO;
    return instance;
}

- (NSDictionary *)toDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([self isValid]) {
        NSNumber *recevierOrSpeaker = [[NSNumber alloc] initWithBool: _recevierOrSpeaker];
        [dict setObject:recevierOrSpeaker forKey:@"recevierOrSpeaker"];
    }
    else
    {
        NIMLogErr(@"invalid app info");
    }
    return dict;
}

@end

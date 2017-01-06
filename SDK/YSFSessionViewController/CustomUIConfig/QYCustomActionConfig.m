#import "QYCustomActionConfig.h"

@implementation QYCustomActionConfig

+ (instancetype)sharedInstance
{
    static QYCustomActionConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QYCustomActionConfig alloc] init];
    });
    return instance;
}

@end

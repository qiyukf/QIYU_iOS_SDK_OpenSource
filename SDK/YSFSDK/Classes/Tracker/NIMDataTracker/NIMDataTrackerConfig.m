//
//  NIMDataTrackerConfig.m
//  NIMSDK
//
//  Created by amao on 2017/12/20.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMDataTrackerConfig.h"
#import "NIMDataTrackerCategory.h"

@interface YSF_NIMDataTrackerConfig()
@property (nonatomic,strong)    NSDictionary    *categories;
@end


@implementation YSF_NIMDataTrackerConfig
- (instancetype)init
{
    if (self = [super init])
    {
        _categories  = @{@(YSF_NIMDataTrackerConfigCategoryDevice)  : @"dev",
                         @(YSF_NIMDataTrackerConfigCategoryCarrier) : @"corp",
                         @(YSF_NIMDataTrackerConfigCategoryApp)     : @"source",
                         @(YSF_NIMDataTrackerConfigCategoryWifi)    : @"wifiinfo",
                         
                         };
    }
    return self;
}

- (BOOL)trackable
{
    return [_serverConfig ysfdt_jsonBool:@"enable"];
}

- (NSArray *)trackableCategories
{
    NSMutableArray *categories = [NSMutableArray array];
    NSArray *allCategories = [_categories allKeys];
    for (NSNumber *category in allCategories)
    {
        if ([self shouldTrackCategory:category])
        {
            [categories addObject:category];
        }
    }
    return categories;
}

- (void)markCategoriesTracked:(NSArray *)categories
{
    NSDate *now = [NSDate date];
    for (NSNumber *category in categories)
    {
        NSString *key = [self keyByCategory:category];
        [[NSUserDefaults standardUserDefaults] setObject:now
                                                  forKey:key];
    }
}

- (NSString *)keyByCategory:(NSNumber *)category
{
    return [NSString stringWithFormat:@"n_config_category_20171220_%zd",[category integerValue]];
}

- (BOOL)shouldTrackCategory:(NSNumber *)category
{
    BOOL should = NO;
    NSString *localKey = [self keyByCategory:category];
    NSString *remoteKey = _categories[category];
    if ([localKey length] && [remoteKey length])
    {
        NSDate *lastTrackDate = [[NSUserDefaults standardUserDefaults] objectForKey:localKey];
        long long duration = [_serverConfig ysfdt_jsonLongLong:remoteKey];
        if ([lastTrackDate isKindOfClass:[NSDate class]])
        {
            NSDate *now = [NSDate date];
            NSTimeInterval diff =  [now timeIntervalSinceDate:lastTrackDate];
            if (diff <= 0 || diff > duration)
            {
                should = YES;
            }
        }
        else
        {
            should = YES;   //本地没记录上次时间，则进行统计
        }
    }
    return should;
}

@end

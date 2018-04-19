//
//  NIMDataTrackerCategory.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMDataTrackerCategory.h"

@implementation NSMutableDictionary (YSF_NIMDataTracker)
- (void)ysfdt_setObject:(id)object
                 forKey:(NSString *)key
{
    BOOL validObject = [object isKindOfClass:[NSString class]] ||
                       [object isKindOfClass:[NSNumber class]] ||
                       ([object isKindOfClass:[NSDictionary class]] && [(NSDictionary *)object count] > 0) ||
                       ([object isKindOfClass:[NSArray class]] && [(NSArray *)object count] > 0);
    if (validObject && key != nil)
    {
        [self setObject:object
                 forKey:key];
    }
}
@end

@implementation NSDictionary (YSF_NIMDataTracker)

- (BOOL)ysfdt_jsonBool:(id)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]])
    {
        return [object boolValue];
    }
    return NO;
}

- (long long)ysfdt_jsonLongLong:(id)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]])
    {
        return [object longLongValue];
    }
    return 0;
}


@end

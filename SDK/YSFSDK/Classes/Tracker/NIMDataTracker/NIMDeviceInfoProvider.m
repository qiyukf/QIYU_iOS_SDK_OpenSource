//
//  NIMDeviceInfoProvider.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMDeviceInfoProvider.h"
#import "NIMDataTrackerCategory.h"

@implementation YSF_NIMDeviceInfoProvider

- (instancetype)init
{
    if (self = [super init])
    {
        [self commomInit];
    }
    return self;
}

- (void)commomInit
{
    _brand          =   @"Apple";
    _model          =   [[UIDevice currentDevice] model];
    _diskSize       =   [self totalDiskSize];
    _memorySize     =   [self totalMemorySize];
    _systemName     =   [[UIDevice currentDevice] systemName];
    _systemVersion  =   [[UIDevice currentDevice] systemVersion];
    _language       =   [[NSLocale preferredLanguages] firstObject];
    _timeZone       =   [[NSTimeZone localTimeZone] name];
    
}

- (int64_t)totalDiskSize
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory()
                                                                                       error:nil];
    return [[attributes objectForKey:NSFileSystemSize] longLongValue];
}

- (int64_t)totalMemorySize
{
    return (int64_t)[[NSProcessInfo processInfo] physicalMemory];
}

- (NSDictionary *)toJsonDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict ysfdt_setObject:_brand
                   forKey:@"brand"];
    [dict ysfdt_setObject:_model
                   forKey:@"model"];
    [dict ysfdt_setObject:@(_diskSize)
                   forKey:@"disk_size"];
    [dict ysfdt_setObject:@(_memorySize)
                   forKey:@"memory_size"];
    [dict ysfdt_setObject:_systemName
                   forKey:@"system_name"];
    [dict ysfdt_setObject:_systemVersion
                   forKey:@"system_version"];
    [dict ysfdt_setObject:_language
                   forKey:@"language"];
    [dict ysfdt_setObject:_timeZone
                   forKey:@"timezone"];
    return dict;
    
}
@end

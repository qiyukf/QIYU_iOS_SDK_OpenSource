//
//  NIMHostAppInfoProvider.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMHostAppInfoProvider.h"
#import "NIMDataTrackerCategory.h"

@implementation YSF_NIMHostAppInfoProvider
- (instancetype)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *infos = [bundle infoDictionary];
    _appId      = [bundle bundleIdentifier];
    _appName    = [infos objectForKey:@"CFBundleDisplayName"];
    _appVersion = [infos objectForKey:@"CFBundleVersion"];

}

- (NSDictionary *)toJsonDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict ysfdt_setObject:_appId
                   forKey:@"app_id"];
    [dict ysfdt_setObject:_appName
                   forKey:@"app_name"];
    [dict ysfdt_setObject:_appVersion
                   forKey:@"app_version"];
    return dict;
}
@end

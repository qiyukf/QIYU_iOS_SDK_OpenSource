//
//  NIMWifiInfoProvider.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMWifiInfoProvider.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NIMDataTrackerCategory.h"
#import "YSFReachability.h" //各个 SDK/App 替换成自己的实现


@implementation YSF_NIMWifiInfoProvider
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
    if ([[YSFReachability reachabilityForInternetConnection] isReachableViaWiFi])
    {
        NSString *bssid = (__bridge NSString *)kCNNetworkInfoKeyBSSID;
        NSString *ssid = (__bridge NSString *)kCNNetworkInfoKeySSID;
        NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
        for (NSString *interface in interfaces)
        {
            NSDictionary *info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
            if (info[bssid] && info[ssid])
            {
                _bssid = info[bssid];
                _ssid = info[ssid];
                break;
            }
        }
    }
}

- (NSDictionary *)toJsonDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict ysfdt_setObject:_ssid
                   forKey:@"ssid"];
    [dict ysfdt_setObject:_bssid
                   forKey:@"bssid"];
    return dict;
}
@end

//
//  NIMWifiInfoProvider.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSF_NIMWifiInfoProvider : NSObject
@property (nonatomic,copy)  NSString    *bssid;

@property (nonatomic,copy)  NSString    *ssid;

- (NSDictionary *)toJsonDict;
@end

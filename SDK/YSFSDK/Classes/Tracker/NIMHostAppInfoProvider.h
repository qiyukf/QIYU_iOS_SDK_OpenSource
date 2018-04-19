//
//  NIMHostAppInfoProvider.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSF_NIMHostAppInfoProvider : NSObject
@property (nonatomic,copy)  NSString    *appId;

@property (nonatomic,copy)  NSString    *appName;

@property (nonatomic,copy)  NSString    *appVersion;

- (NSDictionary *)toJsonDict;
@end

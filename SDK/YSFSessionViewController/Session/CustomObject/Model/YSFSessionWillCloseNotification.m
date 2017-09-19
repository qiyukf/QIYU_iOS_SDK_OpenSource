//
//  YSFCloseService.m
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFSessionWillCloseNotification.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFSessionWillCloseNotification

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFSessionWillCloseNotification *instance = [[YSFSessionWillCloseNotification alloc] init];
    instance.message = [dict ysf_jsonString:YSFApiKeyMessage];
    return instance;
}

@end

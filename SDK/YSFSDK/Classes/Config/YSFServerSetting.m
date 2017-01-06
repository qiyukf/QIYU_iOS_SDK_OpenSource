//
//  YSFServerSetting.m
//  YSFSDK
//
//  Created by amao on 9/1/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFServerSetting.h"

@implementation YSFServerSetting
- (instancetype)init
{
    if (self = [super init]) {
        _apiAddress = @"https://nim.qiyukf.com/";
    }
    return self;
}

- (void)update:(YSFServerSetting *)setting
{
    if ([setting.apiAddress length])
    {
        self.apiAddress = setting.apiAddress;
    }
}
@end

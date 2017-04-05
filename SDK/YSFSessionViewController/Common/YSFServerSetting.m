//
//  YSFServerSetting.m
//  YSFSDK
//
//  Created by amao on 9/1/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFServerSetting.h"

@implementation YSFServerSetting

+ (instancetype)sharedInstance
{
    static YSFServerSetting *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFServerSetting alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _apiAddress = @"https://nim.qiyukf.com/";
    }
    return self;
}

@end

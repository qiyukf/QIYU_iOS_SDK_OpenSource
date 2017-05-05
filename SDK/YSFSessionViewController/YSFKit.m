//
//  YSFKit.m
//  YSFKit
//
//  Created by amao on 8/14/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFKit.h"
#import "QYCustomUIConfig.h"

@implementation YSFSessionUserInfo

@end

@interface YSFKit()

/**
 *  YSFKit资源所在的bundle名称。
 */
@property (nonatomic,copy)      NSString *bundleName;

/**
 *  YSFKit自定义资源所在的bundle名称。
 */
@property (nonatomic,copy)      NSString *customBundleName;

@end

@implementation YSFKit
- (instancetype)init
{
    if (self = [super init]) {
        _bundleName = @"QYResource.bundle";
        _customBundleName = @"QYCustomResource.bundle";
    }
    return self;
}

+ (instancetype)sharedKit
{
    static YSFKit *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFKit alloc] init];
    });
    return instance;
}

- (YSFSessionUserInfo *)infoByCustomer:(YSF_NIMMessage *)message
{
    YSFSessionUserInfo *member;
    if (_provider && [_provider respondsToSelector:@selector(infoByCustomer:)]) {
        member = [_provider infoByCustomer:message];
    }
    return member;
}

- (YSFSessionUserInfo *)infoByService:(YSF_NIMMessage *)message
{
    YSFSessionUserInfo *member;
    if (_provider && [_provider respondsToSelector:@selector(infoByService:)]) {
        member = [_provider infoByService:message];
    }
    return member;
}

@end

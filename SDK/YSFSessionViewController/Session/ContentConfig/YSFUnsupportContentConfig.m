//
//  NIMUnsupportContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFUnsupportContentConfig.h"

@implementation YSFUnsupportContentConfig
+ (instancetype)sharedConfig
{
    static YSFUnsupportContentConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFUnsupportContentConfig alloc] init];
    });
    return instance;
}

- (CGSize)contentSize:(CGFloat)cellWidth
{
    return CGSizeMake(100.f, 40.f);
}

- (NSString *)cellContent
{
    return @"YSFSessionUnknowContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ?
    UIEdgeInsetsMake(11.f,11.f,9.f,15.f) : UIEdgeInsetsMake(11.f, 15.f, 9.f, 9.f);
}

@end

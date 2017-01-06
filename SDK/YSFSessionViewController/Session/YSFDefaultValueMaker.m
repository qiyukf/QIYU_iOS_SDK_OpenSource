//
//  NIMDefaultValueMaker.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFDefaultValueMaker.h"
#import "YSFKitUtil.h"

@implementation YSFDefaultValueMaker

+ (instancetype)sharedMaker{
    static YSFDefaultValueMaker *maker;
    if (!maker) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            maker = [[YSFDefaultValueMaker alloc] init];
        });
    }
    return maker;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _cellLayoutDefaultConfig = [[YSFCellLayoutDefaultConfig alloc] init];
    }
    return self;
}

- (CGFloat)maxTipPadding{
    return 20.f;
}

@end

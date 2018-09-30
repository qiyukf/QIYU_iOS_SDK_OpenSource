//
//  NIMDefaultValueMaker.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFDefaultValueMaker.h"
#import "YSFKitUtil.h"
#import "YSFDianZanViewLayoutDefaultConfig.h"

@interface YSFDefaultValueMaker ()
@property (nonatomic, strong) id<YSFDianZanViewLayoutConfig> dianZanViewLayoutConfig;
@end

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

- (id<YSFDianZanViewLayoutConfig>)dianZanViewLayoutConfig
{
    if (!_dianZanViewLayoutConfig) {
        id<YSFDianZanViewLayoutConfig> dianZanViewTempLayoutConfig = nil;
        
        if (self.dianZanViewLayoutConfigBlock) {
            dianZanViewTempLayoutConfig = self.dianZanViewLayoutConfigBlock();
        }
        
        if (!dianZanViewTempLayoutConfig) {
            dianZanViewTempLayoutConfig = [[YSFDianZanViewLayoutDefaultConfig alloc] init];
        }
        
        _dianZanViewLayoutConfig = dianZanViewTempLayoutConfig;
    }
    
    return _dianZanViewLayoutConfig;
}

- (CGFloat)maxTipPadding{
    return 20.f;
}

@end

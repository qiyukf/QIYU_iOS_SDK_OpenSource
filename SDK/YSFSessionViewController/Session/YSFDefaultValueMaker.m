//
//  NIMDefaultValueMaker.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFDefaultValueMaker.h"
#import "YSFKitUtil.h"

@interface YSFDefaultValueMaker ()
@property (nonatomic, strong) id<YSFExtraCellLayoutConfig> extraCellLayoutConfig;
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

- (id<YSFExtraCellLayoutConfig>)extraCellLayoutConfig {
    if (!_extraCellLayoutConfig) {
        id<YSFExtraCellLayoutConfig> extraCellTempLayoutConfig = nil;
        if (self.extraCellLayoutConfigBlock) {
            extraCellTempLayoutConfig = self.extraCellLayoutConfigBlock();
        }
        if (!extraCellTempLayoutConfig) {
            extraCellTempLayoutConfig = [[YSFExtraCellLayoutDefaultConfig alloc] init];
        }
        _extraCellLayoutConfig = extraCellTempLayoutConfig;
    }
    return _extraCellLayoutConfig;
}

- (CGFloat)maxTipPadding {
    return 20.f;
}

@end

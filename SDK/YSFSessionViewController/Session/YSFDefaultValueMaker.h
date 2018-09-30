//
//  NIMDefaultValueMaker.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"
#import "YSFCellLayoutDefaultConfig.h"
#import "YSFDianZanViewLayoutConfig.h"

typedef id<YSFDianZanViewLayoutConfig> (^YSFDianZanViewLayoutConfigBlock)();

@interface YSFDefaultValueMaker : NSObject

+ (instancetype)sharedMaker;

@property (nonatomic,readonly) YSFCellLayoutDefaultConfig *cellLayoutDefaultConfig;

@property (nonatomic, readonly) id<YSFDianZanViewLayoutConfig> dianZanViewLayoutConfig;

@property (nonatomic, copy) YSFDianZanViewLayoutConfigBlock dianZanViewLayoutConfigBlock;

- (CGFloat)maxTipPadding;

@end

//
//  NIMDefaultValueMaker.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"
#import "YSFCellLayoutDefaultConfig.h"
#import "YSFExtraCellLayoutConfig.h"
#import "YSFExtraCellLayoutDefaultConfig.h"

typedef id<YSFExtraCellLayoutConfig> (^YSFExtraCellLayoutConfigBlock)();

@interface YSFDefaultValueMaker : NSObject

+ (instancetype)sharedMaker;

@property (nonatomic, readonly) YSFCellLayoutDefaultConfig *cellLayoutDefaultConfig;

@property (nonatomic, readonly) id<YSFExtraCellLayoutConfig> extraCellLayoutConfig;

@property (nonatomic, copy) YSFExtraCellLayoutConfigBlock extraCellLayoutConfigBlock;

- (CGFloat)maxTipPadding;

@end

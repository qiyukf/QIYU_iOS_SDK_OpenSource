//
//  NIMDefaultValueMaker.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"
#import "YSFCellLayoutDefaultConfig.h"
@interface YSFDefaultValueMaker : NSObject

+ (instancetype)sharedMaker;

@property (nonatomic,readonly) YSFCellLayoutDefaultConfig *cellLayoutDefaultConfig;

- (CGFloat)maxTipPadding;

@end

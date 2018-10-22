//
//  YSFExtraCellLayoutDefaultConfig.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/10/8.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFExtraCellLayoutDefaultConfig.h"

@implementation YSFExtraCellLayoutDefaultConfig

- (CGSize)extraViewSize:(YSFMessageModel *)model {
    return CGSizeZero;
}

- (Class)extraViewClass {
    return nil;
}

- (UIEdgeInsets)extraViewInsets:(YSFMessageModel *)model {
    return UIEdgeInsetsZero;
}

@end

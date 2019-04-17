//
//  YSFTools.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFTools.h"


CGFloat ROUND(CGFloat X) {
    return (floorf(((X) - floorf(X)) * 2) + floorf(X));
}

CGFloat ROUND_SCALE(CGFloat X) {
    CGFloat scale = [UIScreen mainScreen].scale;
    if(scale == 1)
        return ROUND(X);
    else
        return ((floor((X * scale - floor(X * scale)) * 2) + floor(X * scale))/scale);
}


@implementation YSFTools

@end

//
//  YSFStartServiceLayout.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFInviteEvaluationCellLayoutConfig.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFMessageModel.h"

@implementation YSFInviteEvaluationCellLayoutConfig


- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width
{
    return CGSizeMake(width, 125);
}

- (NSString *)cellContent:(YSFMessageModel *)model
{
    return @"YSFSessionInviteEvaluationContentView";
}


- (UIEdgeInsets)cellInsets:(YSFMessageModel *)model
{
    return UIEdgeInsetsZero;
}


- (UIEdgeInsets)contentViewInsets:(YSFMessageModel *)model
{
    return UIEdgeInsetsZero;
}

- (BOOL)shouldShowAvatar:(YSFMessageModel *)model
{
    return NO;
}

- (BOOL)shouldShowNickName:(YSFMessageModel *)model
{
    return NO;
}

@end
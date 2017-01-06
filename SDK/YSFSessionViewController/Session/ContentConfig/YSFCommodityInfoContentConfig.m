//
//  YSFProductInfoContentConfig.m
//  YSFSessionViewController
//
//  Created by JackyYu on 16/5/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFCommodityInfoContentConfig.h"

@implementation YSFCommodityInfoContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat bubbleLeftToContent = 14;
    CGFloat contentRightToBubble = 14;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    return CGSizeMake(msgContentMaxWidth, 87);
}

- (NSString *)cellContent
{
    return @"YSFSessionCommodityInfoContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(9, 12, 5, 14) : UIEdgeInsetsMake(9, 14, 5, 12);
}


@end

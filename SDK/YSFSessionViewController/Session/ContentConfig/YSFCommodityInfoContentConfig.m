//
//  YSFProductInfoContentConfig.m
//  YSFSessionViewController
//
//  Created by JackyYu on 16/5/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFCommodityInfoContentConfig.h"
#import "YSFCommodityInfoShow.h"
#import "QYCommodityInfo.h"

@implementation YSFCommodityInfoContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat bubbleLeftToContent = 14;
    CGFloat contentRightToBubble = 14;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    CGFloat height = 102;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFCommodityInfoShow *attachment = (YSFCommodityInfoShow *)object.attachment;
    if (attachment.orderId.length > 0) {
        height += 30;
    }
    if (attachment.orderTime.length > 0) {
        height += 30;
    }
    if (attachment.activity.length > 0) {
        height += 36;
    }
    __block CGFloat right = 5;
    __block CGFloat top = 0;
    [attachment.tagsArray enumerateObjectsUsingBlock:^(QYCommodityTag *tag, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [[UIButton alloc] init];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitle:tag.label forState:UIControlStateNormal];
        [button sizeToFit];
        button.ysf_frameWidth += 20;
        button.ysf_frameLeft = right + 10;
        if (button.ysf_frameRight > msgBubbleMaxWidth - 10) {
            top += 22 + 10;
            right = 5;
            button.ysf_frameLeft = right + 10;
        }
        button.ysf_frameTop = top;
        button.ysf_frameHeight = 22;
        right = button.ysf_frameRight;
    }];
    if (attachment.tagsArray.count > 0) {
        height += 14 + top + 22;
    }
    
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFSessionCommodityInfoContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0, 12, 0, 14) : UIEdgeInsetsMake(0, 14, 0, 12);
}


@end

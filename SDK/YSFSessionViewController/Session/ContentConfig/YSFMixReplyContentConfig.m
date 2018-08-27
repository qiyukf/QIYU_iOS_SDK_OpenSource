//
//  YSFMixReplyContentConfig.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/8/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMixReplyContentConfig.h"
#import "YSFMixReply.h"

@implementation YSFMixReplyContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth {
    YSF_NIMCustomObject *object = self.message.messageObject;
    YSFMixReply *mixReply = (YSFMixReply *)object.attachment;
    
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    CGFloat height = 13;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.0f];
    label.text = mixReply.label;
    label.frame = CGRectMake(0, 0, msgContentMaxWidth - 28, 0);
    [label sizeToFit];
    height += label.ysf_frameHeight;
    height += 13 + 34 * mixReply.actionList.count + 15 * (mixReply.actionList.count + 1);
    
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent {
    return @"YSFMixReplyContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0,0,0,0);
}

@end

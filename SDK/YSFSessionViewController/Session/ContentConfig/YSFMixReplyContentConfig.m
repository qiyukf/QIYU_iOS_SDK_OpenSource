//
//  YSFMixReplyContentConfig.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/8/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMixReplyContentConfig.h"
#import "YSFMixReply.h"
#import "NSString+FileTransfer.h"
#import "NSAttributedString+YSF.h"
#import "YSFCoreText.h"
#import "QYCustomUIConfig.h"

@implementation YSFMixReplyContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth {
    YSF_NIMCustomObject *object = self.message.messageObject;
    YSFMixReply *mixReply = (YSFMixReply *)object.attachment;
    
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat offsetX = 0;
    __block CGFloat offsetY = 0;
    
    NSString *labelStr = mixReply.label;
    NSAttributedString *attrStr = [labelStr ysf_attributedString:self.message.isOutgoingMsg];
    if (attrStr.length) {
        CGSize size = [attrStr intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
        offsetX = msgContentMaxWidth;
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
    
    [mixReply.actionList enumerateObjectsUsingBlock:^(YSFAction *action, NSUInteger idx, BOOL *stop) {
        NSString *title = action.validOperation;
        if (title.length) {
            YSFAttributedLabel *attrLabel = [self getAttrubutedLabel];
            [attrLabel setText:title];
            CGSize size = [attrLabel sizeThatFits:CGSizeMake(msgContentMaxWidth - 15, CGFLOAT_MAX)];
            offsetY += 15.5;
            offsetY += size.height;
            offsetY += -9;
        }
    }];
    offsetY += 22;
    
    return CGSizeMake(offsetX, offsetY);
}

- (NSString *)cellContent {
    return @"YSFMixReplyContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0, 18, 0, 12);
}

- (YSFAttributedLabel *)getAttrubutedLabel {
    YSFAttributedLabel *label = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.underLineForLink = NO;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:16.f];
    label.highlightColor = YSFRGBA2(0x1a000000);
    label.backgroundColor = [UIColor clearColor];
    QYCustomUIConfig *config = [QYCustomUIConfig sharedInstance];
    if (self.message.isOutgoingMsg) {
        label.textColor = config.customMessageTextColor;
        label.linkColor = config.customMessageHyperLinkColor;
    } else {
        label.textColor = config.serviceMessageTextColor;
        label.linkColor = config.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = self.message.isOutgoingMsg ? config.customMessageTextFontSize : config.serviceMessageTextFontSize;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

@end

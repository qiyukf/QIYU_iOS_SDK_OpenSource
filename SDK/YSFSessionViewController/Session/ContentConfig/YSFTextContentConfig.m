//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFTextContentConfig.h"
#import "QYCustomUIConfig+Private.h"
#import "YSFAttributedLabel+YSF.h"
#import "YSFMessageModel.h"
#import "YSFApiDefines.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFTextContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth {
    //字号
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    CGFloat fontSize = self.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    //去掉垃圾词汇
    NSString *text = self.message.text;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.message.isOutgoingMsg && !uiConfig.showTransWords) {
        text = [self.message getTextWithoutTrashWords];
    }
    
    YSFAttributedLabel *label = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:fontSize];
    if (self.message.isPushMessageType) {
        [label ysf_setText:@""];
        [label appendHTMLText:text];
    } else {
        [label ysf_setText:text];
    }
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGSize size = [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
    if (self.message.isPushMessageType && self.message.actionText.length) {
        size.width = msgContentMaxWidth;
        size.height += 44;
    }
    if (size.height < 26) {
        size.height = 26;
    }
    return size;
}

- (NSString *)cellContent {
    return @"YSFSessionTextContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(9,12,5,14) : UIEdgeInsetsMake(9,14,5,12);
}

@end

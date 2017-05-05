//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFTextContentConfig.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"
#import "YSFAttributedLabel+YSF.h"

@implementation YSFTextContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    YSFAttributedLabel *label = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    CGFloat fontSize = self.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    label.font = [UIFont systemFontOfSize:fontSize];
    NSString *text = self.message.text;
    if (self.message.isPushMessageType) {
        [label ysf_setText:@""];
        [label appendHTMLText:text];
    }
    else {
        [label ysf_setText:text];
    }
    
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat bubbleLeftToContent  = 14;
    CGFloat contentRightToBubble = 14;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    CGSize size = [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
    if (size.height < 26) {
        size.height = 26;
    }
    return size;
}

- (NSString *)cellContent
{
    return @"YSFSessionTextContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(9,12,5,14) : UIEdgeInsetsMake(9,14,5,12);
}
@end

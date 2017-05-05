//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFKFBypassContentConfig.h"
#import "YSFMessageModel.h"
#import "YSFKFBypassNotification.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"


@implementation YSFKFBypassContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat offsetX = msgContentMaxWidth;
    __block CGFloat offsetY = 0;
    
    YSFAttributedLabel *answerLabel = [self newAttrubutedLabel];
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFKFBypassNotification *attachment = (YSFKFBypassNotification *)object.attachment;
    NSString *tmpAnswerLabel = [attachment.message unescapeHtml];
    [answerLabel appendHTMLText:tmpAnswerLabel];
    if (answerLabel.attributedString.length > 0) {
        CGSize size = [answerLabel sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
        offsetY += 12;
        offsetY += size.height;
        offsetY += 12;
    }
    
    [attachment.entries enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *question = [dict objectForKey:YSFApiKeyLabel];
        if (question) {
            YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
            [questionLabel setText:question];
            CGSize size = [questionLabel sizeThatFits:CGSizeMake(msgContentMaxWidth - 15, CGFLOAT_MAX)];
            offsetY += 12;
            offsetY += size.height;
            offsetY += 12;
        }
    }];
    
    //    attachment.rawStringForCopy = label.attributedString.string;
    
    return CGSizeMake(offsetX, offsetY);

}

- (NSString *)cellContent
{
    return @"YSFSessionKFBypassContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,12,0,18) : UIEdgeInsetsMake(0,18,0,12);
}



- (YSFAttributedLabel *)newAttrubutedLabel
{
    YSFAttributedLabel *answerLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    answerLabel.numberOfLines = 0;
    answerLabel.underLineForLink = NO;
    answerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    answerLabel.font = [UIFont systemFontOfSize:16.f];
    answerLabel.highlightColor = YSFRGBA2(0x1a000000);
    answerLabel.backgroundColor = [UIColor clearColor];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.message.isOutgoingMsg) {
        answerLabel.textColor = uiConfig.customMessageTextColor;
        answerLabel.linkColor = uiConfig.customMessageHyperLinkColor;
    }
    else {
        answerLabel.textColor = uiConfig.serviceMessageTextColor;
        answerLabel.linkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = self.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    answerLabel.font = [UIFont systemFontOfSize:fontSize];
    return answerLabel;
}

@end

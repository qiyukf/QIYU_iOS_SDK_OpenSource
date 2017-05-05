//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFMachineContentConfig.h"
#import "YSFMessageModel.h"
#import "YSFMachineResponse.h"
#import "QYCustomUIConfig.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"


@implementation YSFMachineContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat offsetX = 0;
    __block CGFloat offsetY = 0;
    
    YSFAttributedLabel *answerLabel = [self newAttrubutedLabel];
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFMachineResponse *attachment = (YSFMachineResponse *)object.attachment;
    NSString *tmpAnswerLabel = [attachment.answerLabel unescapeHtml];
    [answerLabel appendHTMLText:tmpAnswerLabel];
    if (answerLabel.attributedString.length > 0) {
        CGSize size = [answerLabel sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
        offsetX = msgContentMaxWidth;
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
    
    if (attachment.answerArray.count == 1 && !attachment.isOneQuestionRelevant) {
        YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
        NSString *answer = @"";
        NSDictionary *dict = [attachment.answerArray objectAtIndex:0];
//        if (attachment.isOneQuestionRelevant) {
//            NSUInteger start = questionLabel.attributedString.length + answer.length;
//            NSString *question = [dict objectForKey:YSFApiKeyQuestion];
//            if (question) {
//                answer = [answer stringByAppendingString:question];
//            }
//        }
//        else {
            NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
            if (oneAnswer) {
                answer = [answer stringByAppendingString:oneAnswer];
            }
//        }
        answer = [answer unescapeHtml];
        [questionLabel appendHTMLText:answer];
        CGSize size = [questionLabel sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
        if (offsetX == 0) {
            offsetX = size.width;
        }
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
    else if ((attachment.answerArray.count == 1 && attachment.isOneQuestionRelevant)
             || attachment.answerArray.count > 1)
    {
        offsetX = msgContentMaxWidth;
        [attachment.answerArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *question = [dict objectForKey:YSFApiKeyQuestion];
            if (question) {
                YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
                [questionLabel setText:question];
                CGSize size = [questionLabel sizeThatFits:CGSizeMake(msgContentMaxWidth - 15, CGFLOAT_MAX)];
                offsetY += 15.5;
                offsetY += size.height;
                offsetY += 13;
            }
        }];
        
    }
    
    if (attachment.operatorHint && attachment.operatorHintDesc.length > 0) {
        offsetX = msgContentMaxWidth;
        YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
        [questionLabel appendHTMLText:attachment.operatorHintDesc];
        CGSize size = [questionLabel sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
//    attachment.rawStringForCopy = label.attributedString.string;
    
    return CGSizeMake(offsetX, offsetY);
}

- (NSString *)cellContent
{
    return @"YSFSessionMachineContentView";
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

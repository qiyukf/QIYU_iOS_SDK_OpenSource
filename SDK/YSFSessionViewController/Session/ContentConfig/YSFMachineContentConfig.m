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
#import "YSFCoreText.h"
#import "YSFRichText.h"
#import "NSAttributedString+YSF.h"
#import "NSString+FileTransfer.h"

@implementation YSFMachineContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat offsetX = 0;
    __block CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFMachineResponse *attachment = (YSFMachineResponse *)object.attachment;
    NSString *tmpAnswerLabel = attachment.answerLabel; //unescapeHtml];
    NSAttributedString *attributedString = [tmpAnswerLabel ysf_attributedString:self.message.isOutgoingMsg];
    
    if (attributedString.length > 0) {
        CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
        offsetX = msgContentMaxWidth;
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
    
    if (attachment.answerArray.count == 1 && !attachment.isOneQuestionRelevant) {
        NSString *answer = @"";
        NSDictionary *dict = [attachment.answerArray objectAtIndex:0];
        NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
        if (oneAnswer) {
            answer = [answer stringByAppendingString:oneAnswer];
        }
        //answer = [answer unescapeHtml];
        NSAttributedString *attributedString = [answer ysf_attributedString:self.message.isOutgoingMsg];
        CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN)];
        if (size.width > msgContentMaxWidth) {
            size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
        }
        
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
                offsetY += -9;
            }
        }];
        offsetY += 22;
    }
    
    if (attachment.operatorHint && attachment.operatorHintDesc.length > 0) {
        offsetX = msgContentMaxWidth;
        
        NSString *tmpOperatorHintDesc = attachment.operatorHintDesc; //[attachment.operatorHintDesc unescapeHtml];
        NSAttributedString *attributedString = [tmpOperatorHintDesc ysf_attributedString:self.message.isOutgoingMsg];
        CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
        
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
//    attachment.rawStringForCopy = label.attributedString.string;
    
    if (attachment.evaluation != YSFEvaluationSelectionTypeInvisible && attachment.shouldShow) {
        offsetY += 45;
        offsetX = msgContentMaxWidth;
        if (attachment.evaluationReason && attachment.evaluation == YSFEvaluationSelectionTypeNo) {
            NSString *showString;
            if (![attachment.evaluationContent isEqualToString:@""]) {
                showString = attachment.evaluationContent;
            } else {
                showString = attachment.evaluationGuide;
            }
            CGFloat height = [showString boundingRectWithSize:CGSizeMake(msgContentMaxWidth, 60) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.height;
            offsetY += height > 25 ? height : 25;
            offsetY += 10;      //底部空白
        }
    }
    //底部显示差评原因
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && (attachment.evaluation == YSFEvaluationSelectionTypeNo) && ![attachment.evaluationContent isEqualToString:@""]) {
        offsetY += 0.5;
        offsetX = msgContentMaxWidth;
        offsetY += 10;  //空白间隙高度
        
        NSString *text = [NSString stringWithFormat:@"差评原因：%@", attachment.evaluationContent];
        CGFloat height = [text boundingRectWithSize:CGSizeMake(msgContentMaxWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.height;
        offsetY += height;
        offsetY += 10;  //空白间隙高度
    }
    
    return CGSizeMake(offsetX, offsetY);
}

- (NSString *)cellContent
{
    return @"YSFSessionMachineContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0, 18, 0, 12);
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

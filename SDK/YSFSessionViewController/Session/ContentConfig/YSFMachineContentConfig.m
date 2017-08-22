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
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"
#import "YSFRichText.h"
#import "NSAttributedString+YSF.h"

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
    NSAttributedString *attributedString = [self _attributedString:tmpAnswerLabel];
    
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
        NSAttributedString *attributedString = [self _attributedString:answer];
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
                offsetY += 13;
            }
        }];
        
    }
    
    if (attachment.operatorHint && attachment.operatorHintDesc.length > 0) {
        offsetX = msgContentMaxWidth;
        
        NSString *tmpOperatorHintDesc = attachment.operatorHintDesc; //[attachment.operatorHintDesc unescapeHtml];
        NSAttributedString *attributedString = [self _attributedString:tmpOperatorHintDesc];
        CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
        
        offsetY += 15.5;
        offsetY += size.height;
        offsetY += 13;
    }
//    attachment.rawStringForCopy = label.attributedString.string;
    
    if (attachment.evaluation != YSFEvaluationSelectionTypeInvisible && attachment.shouldShow) {
        offsetY += 45;
        offsetX = msgContentMaxWidth;
    }
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


- (NSAttributedString *)_attributedString:(NSString *)text
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [text substringWithRange:result.range];
                           if ([[YSFInputEmoticonManager sharedManager] emoticonByTag:rangeText])
                           {
                               if (result.range.location > index)
                               {
                                   NSString *rawText = [text substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"18\" height=\"18\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [text length])
    {
        NSString *rawText = [text substringWithRange:NSMakeRange(index, [text length] - index)];
        resultText = [resultText stringByAppendingString:rawText];
    }
    resultText = [NSString stringWithFormat:@"<span>%@</span>", resultText];
    NSData *data = [resultText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGSize maxImageSize = CGSizeMake(239, 425);
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:maxImageSize], YSFMaxImageSize, @(16), YSFDefaultFontSize, nil];
    
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

@end

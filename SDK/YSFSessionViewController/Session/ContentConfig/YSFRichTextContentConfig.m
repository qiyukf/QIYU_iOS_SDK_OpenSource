//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFRichTextContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFActionList.h"
#import "YSFCoreText.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"
#import "YSFRichText.h"
#import "NSAttributedString+YSF.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFRichTextContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFRichText *attachment = (YSFRichText *)object.attachment;
    
    NSAttributedString *attributedString = [self _attributedString:attachment.content];
    CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(CGFLOAT_HEIGHT_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN)];
    if (size.width > msgContentMaxWidth) {
        size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth, CGFLOAT_HEIGHT_UNKNOWN)];
    }
    if (self.message.isPushMessageType
        && self.message.actionText.length) {
        size.width = msgContentMaxWidth;
        size.height += 44;
    }
    
    return CGSizeMake(size.width, size.height);
}

- (NSString *)cellContent
{
    return @"YSFRichTextContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(9,12,5,14) : UIEdgeInsetsMake(9,14,5,12);
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
                           if ([[YSFInputEmoticonManager sharedManager] emoticonByTag:rangeText]) {
                               if (result.range.location > index) {
                                   NSString *rawText = [text substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"18\" height=\"18\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [text length]) {
        NSString *rawText = [text substringWithRange:NSMakeRange(index, [text length] - index)];
        resultText = [resultText stringByAppendingString:rawText];
    }
    //处理富文本消息中的换行
    if ([resultText containsString:@"\n"] || [resultText containsString:@"\r"]) {
        resultText = [resultText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        resultText = [resultText stringByReplacingOccurrencesOfString:@"\r" withString:@"<br>"];
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

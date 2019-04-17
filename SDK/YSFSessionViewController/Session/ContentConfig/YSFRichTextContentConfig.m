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
#import "YSFEmoticonDataManager.h"
#import "YSFRichText.h"
#import "NSAttributedString+YSF.h"
#import "YSF_NIMMessage+YSF.h"
#import "QYCustomUIConfig.h"

@implementation YSFRichTextContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFRichText *attachment = (YSFRichText *)object.attachment;
    
    NSString *content = attachment.content;
    if (attachment.customEmoticon) {
        CGFloat scale = [UIScreen mainScreen].scale;
        NSString *old_w = nil;
        NSString *new_w = nil;
        NSRange range_w = NSMakeRange(0, 0);
        NSRange range = [content rangeOfString:@"width=\""];
        if (range.location != NSNotFound) {
            NSUInteger i = (range.location + range.length);
            for (i = (range.location + range.length); i < content.length; i++) {
                NSString *str = [content substringWithRange:NSMakeRange(i, 1)];
                if (str.length) {
                    if ([str isEqualToString:@"\""]) {
                        break;
                    }
                }
            }
            range_w = NSMakeRange((range.location + range.length), i - (range.location + range.length));
            old_w = [content substringWithRange:range_w];
            CGFloat width = roundf([old_w floatValue] / scale);
            new_w = [NSString stringWithFormat:@"%ld", (long)width];
        }
        NSString *old_h = nil;
        NSString *new_h = nil;
        NSRange range_h = NSMakeRange(0, 0);
        range = [content rangeOfString:@"height=\""];
        if (range.location != NSNotFound) {
            NSUInteger i = (range.location + range.length);
            for (i = (range.location + range.length); i < content.length; i++) {
                NSString *str = [content substringWithRange:NSMakeRange(i, 1)];
                if (str.length) {
                    if ([str isEqualToString:@"\""]) {
                        break;
                    }
                }
            }
            range_h = NSMakeRange((range.location + range.length), i - (range.location + range.length));
            old_h = [content substringWithRange:range_h];
            CGFloat height = roundf([old_h floatValue] / scale);
            new_h = [NSString stringWithFormat:@"%ld", (long)height];
        }
        if (new_w.length && range_w.length) {
            content = [content stringByReplacingCharactersInRange:range_w withString:new_w];
        }
        if (new_h.length && range_h.length) {
            content = [content stringByReplacingCharactersInRange:NSMakeRange(range_h.location + (new_w.length - old_w.length), range_h.length)
                                                       withString:new_h];
        }
    }
    
    NSAttributedString *attributedString = [self _attributedString:content];
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

- (NSAttributedString *)_attributedString:(NSString *)text {
    //识别文本中的<p>标签，替换为<br>
    NSString *filterString = [self filterHTMLString:text forTag:@"p"];
    if (filterString.length <= 0) {
        filterString = text;
    }
    
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|\\[:[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:filterString
                          options:0
                            range:NSMakeRange(0, [filterString length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [filterString substringWithRange:result.range];
                           if ([[YSFEmoticonDataManager sharedManager] emoticonItemForTag:rangeText]) {
                               if (result.range.location > index) {
                                   NSString *rawText = [filterString substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"21\" height=\"21\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [filterString length]) {
        NSString *rawText = [filterString substringWithRange:NSMakeRange(index, [filterString length] - index)];
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
    CGFloat fontSize = 16.0f;
    if (self.message.isOutgoingMsg) {
        fontSize = [QYCustomUIConfig sharedInstance].customMessageTextFontSize;
    } else {
        fontSize = [QYCustomUIConfig sharedInstance].serviceMessageTextFontSize;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *options = @{
                              YSFMaxImageSize : [NSValue valueWithCGSize:maxImageSize],
                              YSFDefaultFontFamily : YSFStrParam(font.familyName),
                              YSFDefaultFontName : YSFStrParam(font.fontName),
                              YSFDefaultFontSize : @(fontSize),
                              };
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

- (NSString *)filterHTMLString:(NSString *)htmlString forTag:(NSString *)tag {
    if (htmlString.length <= 0 || tag.length <= 0) {
        return htmlString;
    }
    NSString *start = [NSString stringWithFormat:@"<%@>", tag];
    NSString *end = [NSString stringWithFormat:@"</%@>", tag];
    if (![htmlString containsString:start] || ![htmlString containsString:end]) {
        return htmlString;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:htmlString];
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:start intoString:nil];
        [scanner scanUpToString:end intoString:&text];
        if (text.length) {
            NSRange range = [htmlString rangeOfString:text];
            if (range.location != NSNotFound) {
                if ((range.location + start.length) <= [htmlString length]) {
                    htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(range.location, start.length) withString:@""];
                }
                if ((range.location + range.length - start.length) >= 0
                    && (range.location + range.length - start.length + end.length) <= [htmlString length]) {
                    htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(range.location + range.length - start.length, end.length) withString:@"<br>"];
                }
            }
        }
    }
    return htmlString;
}

@end

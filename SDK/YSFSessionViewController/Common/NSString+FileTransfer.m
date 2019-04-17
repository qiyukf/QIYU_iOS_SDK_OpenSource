//
//  NSString+FileTransfer.m
//  YSFSessionViewController
//
//  Created by NetEase on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NSString+FileTransfer.h"
#import "YSFEmoticonDataManager.h"
#import "YSFCoreText.h"
#import "QYCustomUIConfig.h"

@implementation NSString (FileTransfer)

+ (NSString *)getFileSizeTextWithFileLength:(long long)fileLength
{
    if (fileLength < 0) return nil;
    
    NSString *sizeText = nil;
    float fileSize = 0;
    int lastNum = 0;
    
    if ((fileLength / 1024.0 / 1024.0) > 1) {
        fileSize = fileLength / 1024.0 / 1024.0;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fMB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fMB", fileSize];
        }
    } else if ((fileLength / 1024.0) > 1) {
        fileSize = fileLength / 1024.0;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fKB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fKB", fileSize];
        }
    } else {
        fileSize = (float)fileLength;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fB", fileSize];
        }
    }
    
    return sizeText;
}

- (BOOL)isImageByFileName
{
    NSDictionary *dict = @{
                           @"jpg" : @(YES),
                           @"jpeg" : @(YES),
                           @"png" : @(YES),
                           @"gif" : @(YES),
                           @"bmp" : @(YES),
                           @"exif" : @(YES),
                           };
    
    NSString *fileExt = [[self pathExtension] lowercaseString];
    if ([dict objectForKey:fileExt]) {
        return YES;
    }
    
    return NO;
}

- (NSAttributedString *)ysf_attributedString:(BOOL)isOutgoingMsg {
    //识别文本中的<p>标签，替换为<br>
    NSString *filterString = [self filterHTMLString:self forTag:@"p"];
    if (filterString.length <= 0) {
        filterString = self;
    }
    
    //识别文本中的emoji表情，替换为object
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
    UIColor *defaultTextColor = nil;
    UIColor *defaultLinkColor = nil;
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (isOutgoingMsg) {
        defaultTextColor = uiConfig.customMessageTextColor;
        defaultLinkColor = uiConfig.customMessageHyperLinkColor;
    } else {
        defaultTextColor = uiConfig.serviceMessageTextColor;
        defaultLinkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *options = @{
                              YSFMaxImageSize : [NSValue valueWithCGSize:maxImageSize],
                              YSFDefaultFontFamily : YSFStrParam(font.familyName),
                              YSFDefaultFontName : YSFStrParam(font.fontName),
                              YSFDefaultFontSize : @(fontSize),
                              YSFDefaultTextColor : defaultTextColor,
                              YSFDefaultLinkColor : defaultLinkColor,
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

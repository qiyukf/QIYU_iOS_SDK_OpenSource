//
//  NSString+FileTransfer.m
//  YSFSessionViewController
//
//  Created by NetEase on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NSString+FileTransfer.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"
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

- (NSAttributedString *)ysf_attributedString:(BOOL)isOutgoingMsg
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:self
                          options:0
                            range:NSMakeRange(0, [self length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [self substringWithRange:result.range];
                           if ([[YSFInputEmoticonManager sharedManager] emoticonByTag:rangeText])
                           {
                               if (result.range.location > index)
                               {
                                   NSString *rawText = [self substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"18\" height=\"18\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [self length])
    {
        NSString *rawText = [self substringWithRange:NSMakeRange(index, [self length] - index)];
        resultText = [resultText stringByAppendingString:rawText];
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
    }
    else {
        defaultTextColor = uiConfig.serviceMessageTextColor;
        defaultLinkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:maxImageSize], YSFMaxImageSize, @(16), YSFDefaultFontSize, defaultTextColor, YSFDefaultTextColor, defaultLinkColor, YSFDefaultLinkColor, nil];
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

@end

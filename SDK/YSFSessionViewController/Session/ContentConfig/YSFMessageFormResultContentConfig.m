//
//  YSFMessageFormResultContentConfig.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormResultContentConfig.h"
#import "YSFMessageFormResultObject.h"
#import "QYCustomUIConfig.h"

static CGFloat kMessageFormResultTopSpace = 10.0f;
static CGFloat kMessageFormResultLeftSpace = 8.0f;
static CGFloat kMessageFormResultRightSpace = 11.0f;
static CGFloat kMessageFormResultVerticalGap_1 = 5.0f;
static CGFloat kMessageFormResultVerticalGap_2 = 1.0f;
static CGFloat kMessageFormResultHorizontalGap = 5.0f;
static CGFloat kMessageFormResultNameWidth = 56.0f;
static CGFloat kMessageFormResultColonWidth = 12.0f;
static CGFloat kMessageFormResultNameHeight = 18.0f;
static CGFloat kMessageFormResultMaxHeight = 56.0f;


@implementation YSFMessageFormResultContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth {
    CGFloat bubbleMaxWidth = (cellWidth - 112);
    CGFloat contentMaxWidth = bubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFMessageFormResultObject *result = (YSFMessageFormResultObject *)object.attachment;
    
    CGFloat offset_Y = kMessageFormResultTopSpace;
    CGFloat width = bubbleMaxWidth - kMessageFormResultLeftSpace - kMessageFormResultRightSpace;
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    if (result.title.length) {
        CGFloat textHeight = [self caculateLabelHeight:result.title width:width font:font];
        textHeight = MIN(textHeight, kMessageFormResultMaxHeight);
        offset_Y += textHeight;
    }
    offset_Y += kMessageFormResultVerticalGap_1 * 2;
    for (NSDictionary *dict in result.fields) {
        NSString *name = [dict.allKeys firstObject];
        NSString *value = [dict.allValues firstObject];
        if (name.length) {
            if (value.length) {
                CGFloat valueWidth = width - kMessageFormResultNameWidth - kMessageFormResultColonWidth - kMessageFormResultHorizontalGap;
                CGFloat textHeight = [self caculateLabelHeight:value width:valueWidth font:font];
                textHeight = MIN(textHeight, kMessageFormResultMaxHeight);
                offset_Y += textHeight;
            } else {
                offset_Y += kMessageFormResultNameHeight;
            }
        }
        offset_Y += kMessageFormResultVerticalGap_2;
    }
    offset_Y += (kMessageFormResultTopSpace - kMessageFormResultVerticalGap_2);

    return CGSizeMake(contentMaxWidth, offset_Y);
}

- (NSString *)cellContent {
    return @"YSFMessageFormResultContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0, 2, 0, 6) : UIEdgeInsetsMake(0, 6, 0, 2);
}

- (CGFloat)caculateLabelWidth:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    NSDictionary *dict = @{ NSFontAttributeName : font };
    CGFloat textWidth = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:dict
                                             context:nil].size.width;
    textWidth += 2;
    return roundf(textWidth);
}

- (CGFloat)caculateLabelHeight:(NSString *)string width:(CGFloat)width font:(UIFont *)font {
    NSDictionary *dict = @{ NSFontAttributeName : font };
    CGFloat textHeight = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:dict
                                              context:nil].size.height;
    textHeight += 2;
    return roundf(textHeight);
}

@end

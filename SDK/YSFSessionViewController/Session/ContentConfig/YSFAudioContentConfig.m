//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFAudioContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"


@implementation YSFAudioContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    //使用公式 长度 = (最长－最小)*(2/pi)*artan(时间/10)+最小，在10秒时变化逐渐变缓，随着时间增加 无限趋向于最大值
    YSF_NIMAudioObject *audioContent = (YSF_NIMAudioObject*)[self.message messageObject];
    NSInteger secondLength = (audioContent.duration+500)/1000;
    if (secondLength == 0) {
        secondLength = 1;
    }
    CGFloat value  = 2*atan((secondLength-1)/10.0)/M_PI;
    NSInteger audioContentMinWidth = 34;
    NSInteger audioContentMaxWidth = (cellWidth - 170);
    NSInteger audioContentHeight   = 23;
    
    NSDictionary *dict = [self.message.ext ysf_toDict];
    NSString *text = [dict ysf_jsonString:YSFApiKeyContent];
    BOOL loading = NO;
    if (self.message.ext.length > 0 && ![YSF_NIMSDK sharedSDK].sdkOrKf && !self.message.isOutgoingMsg) {
        if (text == nil) {
            loading = YES;
            if ([[KFAudioToTextHandler sharedInstance] audioInTransfering:self.message.messageId]) {
                text = @"文字转换中...";
            }
            else {
                text = @"文字转换失败，点击重新转换";
            }
        }
        else if (text.length == 0) {
            text = @" ";
        }
    }
    
    CGFloat width = (audioContentMaxWidth - audioContentMinWidth)* value + audioContentMinWidth;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.message.isOutgoingMsg && text.length > 0) {
        UIButton *textLabel = [[UIButton alloc] initWithFrame:CGRectZero];
        textLabel.titleLabel.numberOfLines = 0;
        textLabel.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [textLabel setTitle:text forState:UIControlStateNormal];
        
        CGSize size = [textLabel.titleLabel sizeThatFits:CGSizeMake(audioContentMaxWidth, CGFLOAT_MAX)];
        if (loading) {
            size.width += 25;
        }
        if (size.width > width) {
            width = size.width;
        }
        if (width > audioContentMaxWidth) {
            width = audioContentMaxWidth;
        }
        return CGSizeMake(width, audioContentHeight + 20 + size.height);
    }
    else {
        return CGSizeMake(width, audioContentHeight);
    }
}

- (NSString *)cellContent
{
    return @"YSFSessionAudioContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(8,12,9,14) : UIEdgeInsetsMake(8,14,9,12);
}
@end

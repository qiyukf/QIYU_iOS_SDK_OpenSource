//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFRefundDetailContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "YSFAttributedLabel.h"
#import "QYCustomUIConfig.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFRefundDetail.h"


@implementation YSFRefundDetailContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFRefundDetail *refundDetail = (YSFRefundDetail *)object.attachment;
    CGFloat height = 0;
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.f];
    
    height += 13;
    label.text = refundDetail.label;
    label.ysf_frameWidth = msgBubbleMaxWidth - 28;
    [label sizeToFit];
    height += label.ysf_frameHeight;
    
    height += 13;
    height += 13;
    
    label.text = refundDetail.refundStateText;
    label.font = [UIFont systemFontOfSize:15.f];
    label.ysf_frameWidth = msgBubbleMaxWidth - 28;
    [label sizeToFit];
    height += label.ysf_frameHeight;
    height += 13;
    
    for (NSString *content in refundDetail.contentList) {
        label.text = content;
        label.ysf_frameWidth = msgBubbleMaxWidth - 28;
        [label sizeToFit];
        height += label.ysf_frameHeight;
    }
    if (refundDetail.contentList.count > 0) {
        height += (refundDetail.contentList.count - 1) * 13;
    }
    height += 13;
    
    return CGSizeMake(msgBubbleMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFRefundDetailContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

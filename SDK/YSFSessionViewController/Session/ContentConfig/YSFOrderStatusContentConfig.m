//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFOrderStatusContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "QYCustomUIConfig.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFOrderStatus.h"


@implementation YSFOrderStatusContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFOrderStatus *orderStatus = (YSFOrderStatus *)object.attachment;
    
    CGFloat height = 0;
    height += 13;
    
    UILabel *answerLabel = [UILabel new];
    answerLabel.numberOfLines = 0;
    answerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    answerLabel.font = [UIFont systemFontOfSize:16.f];
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 28;
    answerLabel.text = orderStatus.label;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    height += 13;
    height += 13;
    
    answerLabel.text = orderStatus.title;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    height += 13;
    
    height += 34 * orderStatus.actionArray.count + 15 * (orderStatus.actionArray.count - 1);
    
    height += 13;
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFOrderStatusContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

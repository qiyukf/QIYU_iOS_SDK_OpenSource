//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFOrderDetailContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "QYCustomUIConfig.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFOrderDetail.h"

@implementation YSFOrderDetailContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    CGFloat height = 91;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFOrderDetail *orderDetail = (YSFOrderDetail *)object.attachment;
    
    UILabel *answerLabel = [UILabel new];
    answerLabel.numberOfLines = 0;
    answerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    answerLabel.font = [UIFont systemFontOfSize:16.f];
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 40;
    answerLabel.text = orderDetail.label;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 60;
    answerLabel.text = orderDetail.status;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 60;
    answerLabel.text = orderDetail.userName;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 60;
    answerLabel.text = orderDetail.address;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 60;
    answerLabel.text = orderDetail.orderNo;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    answerLabel.ysf_frameWidth = msgContentMaxWidth - 60;
    answerLabel.text = orderDetail.date;
    [answerLabel sizeToFit];
    height += answerLabel.ysf_frameHeight;
    
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFOrderDetailContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

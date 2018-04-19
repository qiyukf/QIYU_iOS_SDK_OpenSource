//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFOrderLogisticContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "QYCustomUIConfig.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFOrderLogistic.h"
#import "YSFMessageModel.h"

@implementation YSFOrderLogisticContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFOrderLogistic *orderLogistic = (YSFOrderLogistic *)object.attachment;
    __block CGFloat height = 0;
    UILabel *logistic = [UILabel new];
    logistic.numberOfLines = 0;
    logistic.font = [UIFont systemFontOfSize:16.f];

    height += 13;
    logistic.text = orderLogistic.label;
    logistic.ysf_frameWidth = msgBubbleMaxWidth - 28;
    [logistic sizeToFit];
    height += logistic.ysf_frameHeight;
    
    height += 13;
    height += 13;

    logistic.text = orderLogistic.title;
    logistic.font = [UIFont systemFontOfSize:15.f];
    logistic.ysf_frameWidth = msgBubbleMaxWidth - 28;
    [logistic sizeToFit];
    height += logistic.ysf_frameHeight;
    height += 13;
    
    [orderLogistic.logistic enumerateObjectsUsingBlock:^(YSFOrderLogisticNode * _Nonnull logisticNode, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx + 1 > 2 && !orderLogistic.fullLogistic) {
            *stop = YES;
        }
        
        logistic.text = logisticNode.logistic;
        logistic.ysf_frameWidth = msgBubbleMaxWidth - 48;
        [logistic sizeToFit];
        height += logistic.ysf_frameHeight;
        height += 4;
        
        logistic.text = logisticNode.timestamp;
        logistic.ysf_frameWidth = msgBubbleMaxWidth - 48;
        [logistic sizeToFit];
        height += logistic.ysf_frameHeight;
    }];
    
    NSUInteger logisticCount = orderLogistic.logistic.count;
    if (logisticCount > 3 && !orderLogistic.fullLogistic) {
        logisticCount = 3;
    }
    if (logisticCount > 0) {
        height += (logisticCount - 1) * 13;
    }
    
    height += 13;
    if (orderLogistic.logistic.count > 3 && !orderLogistic.fullLogistic) {
        height += 44;
    }
    if (orderLogistic.action.validOperation.length > 0 ) {
        height += 44;
    }
    
    return CGSizeMake(msgBubbleMaxWidth, height);

}

- (NSString *)cellContent
{
    return @"YSFOrderLogisticContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

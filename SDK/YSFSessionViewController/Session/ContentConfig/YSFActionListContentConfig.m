//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFActionListContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "YSFAttributedLabel.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFActionList.h"

@implementation YSFActionListContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFActionList *actionList = (YSFActionList *)object.attachment;
    
    CGFloat height = 13;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16.f];
    label.numberOfLines = 0;
    label.text = actionList.label;
    label.frame = CGRectMake(0, 0, msgContentMaxWidth - 28, 0);
    [label sizeToFit];
    height += label.ysf_frameHeight;
    height += 13 + 34 * actionList.actionArray.count + 15 * (actionList.actionArray.count + 1);
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFActionListContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

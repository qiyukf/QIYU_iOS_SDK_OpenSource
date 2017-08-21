//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFActivePageContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFActivePage.h"


@implementation YSFActivePageContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgContentMaxWidth    = (cellWidth - 112);
    CGFloat height = 0;
    height += 90;
    height += 13;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFActivePage *activePage = (YSFActivePage *)object.attachment;
    UILabel *content = [UILabel new];
    content.font = [UIFont systemFontOfSize:15];
    content.numberOfLines = 0;
    content.text = activePage.content;
    content.ysf_frameWidth = msgContentMaxWidth - 33;
    [content sizeToFit];
    height += content.ysf_frameHeight;
    height += 13;
    
    height += 34;
    height += 13;
    
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent
{
    return @"YSFActivePageContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

//
//  YSFMiniProgramPageContentConfig.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMiniProgramPageContentConfig.h"
#import "YSFMiniProgramPage.h"
#import "QYCustomUIConfig.h"

@implementation YSFMiniProgramPageContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth {
    CGFloat msgBubbleMaxWidth = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFMiniProgramPage *miniProgram = (YSFMiniProgramPage *)object.attachment;
    
    CGFloat height = 250;
    if (miniProgram.title.length) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:16.0f];
        label.numberOfLines = 0;
        label.text = miniProgram.title;
        label.ysf_frameWidth = msgContentMaxWidth - 2 * 10;
        [label sizeToFit];
        height += label.ysf_frameHeight;
    }
    return CGSizeMake(msgContentMaxWidth, height);
}

- (NSString *)cellContent {
    return @"YSFMiniProgramPageContentView";
}

-(UIEdgeInsets)contentViewInsets {
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0, 2, 0, 6) : UIEdgeInsetsMake(0, 6, 0, 2);
}

@end

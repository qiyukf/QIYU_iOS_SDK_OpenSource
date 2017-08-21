//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFSubmittedBotFormContentConfig.h"
#import "QYCustomUIConfig.h"
#import "YSFAttributedLabel+YSF.h"
#import "YSFMessageModel.h"
#import "YSFApiDefines.h"
#import "YSF_NIMMessage+YSF.h"
#import "YSFSubmittedBotForm.h"
#import "NIMPathManager.h"

@implementation YSFSubmittedBotFormContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    __block CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFSubmittedBotForm *attachment = (YSFSubmittedBotForm *)object.attachment;
    [attachment.forms enumerateObjectsUsingBlock:^(YSFSubmittedBotFormCell *botFormCell, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16];
        [label setText:botFormCell.label];
        CGSize size = [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
        offsetY += 10;
        offsetY += size.height;
        offsetY += 10;
        
        if ([botFormCell.type isEqualToString:@"image"]) {
            if (botFormCell.imageValue.count > 0) {
                offsetY += 43;
            }
        }
        else {
            UILabel *value = [UILabel new];
            value.numberOfLines = 0;
            value.font = [UIFont systemFontOfSize:16];
            [value setText:botFormCell.value];
            CGSize size2 = [value sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
            offsetY += size2.height;
        }

        offsetY += 10;
    }];
    
    return CGSizeMake(msgContentMaxWidth, offsetY);
}

- (NSString *)cellContent
{
    return @"YSFSubmittedBotFormContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,12,0,18) : UIEdgeInsetsMake(0,18,0,12);
}
@end

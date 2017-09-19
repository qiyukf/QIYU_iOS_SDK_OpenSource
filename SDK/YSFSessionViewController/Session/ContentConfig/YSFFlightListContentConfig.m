//
//  NIMTextContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFFlightListContentConfig.h"
#import "QYCustomUIConfig.h"
#import "YSFAttributedLabel+YSF.h"
#import "YSFMessageModel.h"
#import "YSFApiDefines.h"
#import "YSF_NIMMessage+YSF.h"
#import "YSFFlightList.h"

@implementation YSFFlightListContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFFlightList *fightList = (YSFFlightList *)object.attachment;
    CGFloat msgBubbleMaxWidth    = (cellWidth - 112);
    CGFloat msgContentMaxWidth = msgBubbleMaxWidth - self.contentViewInsets.left - self.contentViewInsets.right;
    
    CGFloat offsetY = 0;
    if (fightList.label.length > 0) {
        offsetY += 26;
        label.text = fightList.label;
        offsetY += [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)].height;
    }

    for (int i = 0; i < fightList.fieldItems.count; i++) {
        YSFFlightItem *item = fightList.fieldItems[i];
        for (NSArray *row in item.fields) {
            CGFloat rowHeight = 0;
            CGFloat columnWidth = (msgBubbleMaxWidth - 5 - (row.count + 1) * 10) / row.count;
            for (YSFFlightInfoField *field in row) {
                if ([field.type isEqualToString:@"image"]) {
                    if (columnWidth > rowHeight) {
                        rowHeight = columnWidth;
                    }
                }
                else {
                    if (field.flag & QYMessageTypeSingleLine) {
                        label.numberOfLines = 1;
                    }
                    else {
                        label.numberOfLines = 3;
                    }
                    
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:field.value];
                    NSRange attributedTextRange = {0,[attributedText length]};
                    if (field.flag & QYMessageTypeBold) {
                        label.font = [UIFont boldSystemFontOfSize:14];
                    }
                    else {
                        label.font = [UIFont systemFontOfSize:14];
                    }
                    if (field.flag & QYMessageTypeItalic) {
                        [attributedText addAttribute:NSObliquenessAttributeName value:@(1) range:attributedTextRange];
                    }
                    if (field.flag & QYMessageTypeUnderline) {
                        [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:attributedTextRange];
                    }
                    label.attributedText = attributedText;

                    CGSize size = [label sizeThatFits:CGSizeMake(columnWidth, CGFLOAT_MAX)];
                    if (size.height > rowHeight) {
                        rowHeight = size.height;
                    }
                }
            }
            rowHeight += 26;
            offsetY += rowHeight;
        }
    }
    
    if (fightList.action != nil) {
        offsetY += 42;
    }
    
    return CGSizeMake(msgContentMaxWidth, offsetY);
}

- (NSString *)cellContent
{
    return @"YSFFlightListContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,12,0,14) : UIEdgeInsetsMake(0,14,0,12);
}
@end

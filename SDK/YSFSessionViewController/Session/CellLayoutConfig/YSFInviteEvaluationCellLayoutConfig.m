//
//  YSFStartServiceLayout.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFInviteEvaluationCellLayoutConfig.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFMessageModel.h"
#import "YSFAttributedLabel.h"

@implementation YSFInviteEvaluationCellLayoutConfig


- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width
{
    YSFAttributedLabel *textLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.ysf_frameWidth = 280 - 30;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFInviteEvaluationObject class]]) {
        YSFInviteEvaluationObject *attachment = (YSFInviteEvaluationObject *)object.attachment;
        if (attachment.evaluationMessageInvite.length > 0) {
            [textLabel setText:attachment.evaluationMessageInvite];
        }
        else {
            [textLabel setText:@"感谢您的咨询，请对我们的服务作出评价"];
        }
    }
    
    [textLabel sizeToFit];

    
    return CGSizeMake(width, 90 + textLabel.ysf_frameHeight);
}

- (NSString *)cellContent:(YSFMessageModel *)model
{
    return @"YSFSessionInviteEvaluationContentView";
}


- (UIEdgeInsets)cellInsets:(YSFMessageModel *)model
{
    return UIEdgeInsetsZero;
}


- (UIEdgeInsets)contentViewInsets:(YSFMessageModel *)model
{
    return UIEdgeInsetsZero;
}

- (BOOL)shouldShowAvatar:(YSFMessageModel *)model
{
    return NO;
}

- (BOOL)shouldShowNickName:(YSFMessageModel *)model
{
    return NO;
}

@end

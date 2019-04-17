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
#import "YSFApiDefines.h"
#import "YSFMacro.h"

@implementation YSFInviteEvaluationCellLayoutConfig


- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width
{
    YSFAttributedLabel *textLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.ysf_frameWidth = 280 - 30;
    
    CGFloat height = 90;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFInviteEvaluationObject class]]) {
        YSFInviteEvaluationObject *attachment = (YSFInviteEvaluationObject *)object.attachment;
        if (attachment.localCommand == YSFCommandInviteEvaluation) {
            if (attachment.inviteText.length > 0) {
                [textLabel setText:attachment.inviteText];
            } else {
                [textLabel setText:@"感谢您的咨询，请对我们的服务作出评价"];
            }
        } else if (attachment.localCommand == YSFCommandSatisfactionResult) {
            [textLabel setText:[NSString stringWithFormat:@"用户提交的服务评价为：%@", YSFStrParam(attachment.evaluationResult)]];
            height = (attachment.inviteStatus == YSFInviteEvaluateStatusHidden) ? 45 : 71;
        }
    }
    
    [textLabel sizeToFit];
    
    return CGSizeMake(width, height + textLabel.ysf_frameHeight);
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

- (CGFloat)headBubbleSpace:(YSFMessageModel *)model {
    return 0;
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

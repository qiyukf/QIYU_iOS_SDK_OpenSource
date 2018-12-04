//
//  YSFStartServiceLayout.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFNotificationCellLayoutConfig.h"
#import "YSFStartServiceObject.h"
#import "YSFEvaluationTipObject.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFNotification.h"
#import "YSFAttributedLabel.h"
#import "YSFBotCustomObject.h"

@implementation YSFNotificationCellLayoutConfig
- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] init];
    label.text = [self formatedMessage:model];
    label.font = [UIFont systemFontOfSize:[QYCustomUIConfig sharedInstance].tipMessageTextFontSize];
    label.numberOfLines = 0;
    CGSize size = [label sizeThatFits:CGSizeMake(width - 112 - 20, CGFLOAT_MAX)];
    CGFloat cellPadding = 11.f;
    return  CGSizeMake(width, size.height + 2 * cellPadding);
}

- (NSString *)cellContent:(YSFMessageModel *)model {
    return @"YSFSessionNotificationContentView";
}

- (UIEdgeInsets)cellInsets:(YSFMessageModel *)model {
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)contentViewInsets:(YSFMessageModel *)model {
    return UIEdgeInsetsZero;
}

- (CGFloat)headBubbleSpace:(YSFMessageModel *)model {
    return 0;
}

- (BOOL)shouldShowAvatar:(YSFMessageModel *)model {
    return NO;
}

- (BOOL)shouldShowNickName:(YSFMessageModel *)model {
    return NO;
}

- (NSString *)formatedMessage:(YSFMessageModel *)model {
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)model.message.messageObject;
    if (model.message.messageType == YSF_NIMMessageTypeTip) {
        return model.message.text;
    } else if ([object.attachment isKindOfClass:[YSFStartServiceObject class]]) {
        YSFStartServiceObject *attachment = (YSFStartServiceObject *)object.attachment;
        if (attachment.transferSession && attachment.transferMessage.length) {
            return attachment.transferMessage;
        }
        if (attachment.accessTip.length) {
            return attachment.accessTip;
        }
        NSString *group = @"";
        if (attachment.message.length > 0 && attachment.humanOrMachine) {
            group = [NSString stringWithFormat:@"%@",attachment.message];
        }
        if (attachment.groupName.length > 0) {
            group = [group stringByAppendingString:[NSString stringWithFormat:@"已连接至%@，",attachment.groupName]];
        }
        NSString *service = [NSString stringWithFormat:@"%@为您服务",attachment.staffName];
        return [group stringByAppendingString:service];
    } else if ([object.attachment isKindOfClass:[YSFEvaluationTipObject class]]) {
        YSFEvaluationTipObject *attachment = (YSFEvaluationTipObject *)object.attachment;
        NSString *text = nil;
        if (attachment.specialThanksTip.length > 0) {
            text = attachment.specialThanksTip;
            text = [text stringByAppendingString:YSFStrParam(attachment.tipModify)];
        } else {
            if (!attachment.tipContent.length) {
                //情况1：服务端返回的感谢文案为空，走原逻辑
                text = [NSString stringWithFormat:@"您对我们的服务评价为：%@。非常感谢！%@", YSFStrParam(attachment.tipResult), YSFStrParam(attachment.tipModify)];
            } else {
                NSRange range = [attachment.tipContent rangeOfString:@"#选择项#"];
                if (range.location != NSNotFound) {
                    //情况2：服务端返回的感谢文案中含有"#选择项#"，将此部分内容替换为结果
                    text = [attachment.tipContent stringByReplacingCharactersInRange:range withString:YSFStrParam(attachment.tipResult)];
                    text = [text stringByAppendingString:YSFStrParam(attachment.tipModify)];
                } else {
                    //情况3：服务端返回的感谢文案中不含"#xxx#"，原样展示
                    text = [attachment.tipContent stringByAppendingString:YSFStrParam(attachment.tipModify)];
                }
            }
        }
        return text;
    } else if ([object.attachment isKindOfClass:[YSFNotification class]]) {
        YSFNotification *attachment = (YSFNotification *)object.attachment;
        return attachment.message;
    } else if ([object.attachment isKindOfClass:[YSFBotCustomObject class]]) {
        return @"";
    } else {
        NSAssert(0, @"not support model");
        return @"";
    }
}

@end

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
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"
#import "YSFNotification.h"

@implementation YSFNotificationCellLayoutConfig


- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width
{
    UILabel *label      = [[UILabel alloc] init];
    label.text          = [self formatedMessage:model];
    label.font          = [UIFont systemFontOfSize:[QYCustomUIConfig sharedInstance].tipMessageTextFontSize];
    label.numberOfLines = 0;
    CGFloat padding     = 20.f;
    CGSize size = [label sizeThatFits:CGSizeMake(width - 2 * padding, CGFLOAT_MAX)];
    CGFloat cellPadding = 11.f;
    return  CGSizeMake(width, size.height + 2 * cellPadding);
}



- (NSString *)cellContent:(YSFMessageModel *)model
{
    return @"YSFSessionNotificationContentView";
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


- (NSString *)formatedMessage:(YSFMessageModel *)model
{
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFStartServiceObject class]]) {
        YSFStartServiceObject *attachment = (YSFStartServiceObject *)object.attachment;
        NSString *group = @"";
        if (attachment.groupName.length > 0) {
            group = [NSString stringWithFormat:@"已连接至%@，",attachment.groupName];
        }
        NSString *service = [NSString stringWithFormat:@"%@为您服务",attachment.staffName];
        return [group stringByAppendingString:service];
    }
    else if ([object.attachment isKindOfClass:[YSFEvaluationTipObject class]]) {
        YSFEvaluationTipObject *attachment = (YSFEvaluationTipObject *)object.attachment;
        return attachment.tipContent;
    }
    else if ([object.attachment isKindOfClass:[YSFNotification class]]) {
        YSFNotification *attachment = (YSFNotification *)object.attachment;
        return attachment.message;
    }
    else {
        NSAssert(0, @"not support model");
        return @"";
    }
}

@end

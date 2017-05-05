//
//  NIMSessionDefaultConfig.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutDefaultConfig.h"
#import "YSFSessionMessageContentView.h"
#import "YSFSessionUnknowContentView.h"
#import "YSFKitUtil.h"
#import "YSFMessageModel.h"
#import "YSFDefaultValueMaker.h"
#import "YSFBaseSessionContentConfig.h"
#import "QYCustomUIConfig.h"

@implementation YSFCellLayoutDefaultConfig

- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)cellWidth{
    id<YSFSessionContentConfig>config = [[YSFSessionContentConfigFactory sharedFacotry] configBy:model.message];
    return [config contentSize:cellWidth];

}

- (NSString *)cellContent:(YSFMessageModel *)model{
    id<YSFSessionContentConfig>config = [[YSFSessionContentConfigFactory sharedFacotry] configBy:model.message];
    NSString *cellContent = [config cellContent];
    return cellContent ? : @"YSFSessionUnknowContentView";
}


- (UIEdgeInsets)contentViewInsets:(YSFMessageModel *)model{
    id<YSFSessionContentConfig>config = [[YSFSessionContentConfigFactory sharedFacotry] configBy:model.message];
    return [config contentViewInsets];
}


- (UIEdgeInsets)cellInsets:(YSFMessageModel *)model{
    CGFloat cellTopToBubbleTop           = 3;
    CGFloat otherNickNameHeight          = 20;
    CGFloat otherBubbleOriginX           = 55;
    CGFloat cellBubbleButtomToCellButtom = 13 + [QYCustomUIConfig sharedInstance].sessionMessageSpacing;
    if (model.message.session.sessionType == YSF_NIMSessionTypeTeam) {
        //要显示名字。。
        return UIEdgeInsetsMake(cellTopToBubbleTop + otherNickNameHeight ,otherBubbleOriginX,cellBubbleButtomToCellButtom, 0);
    }
    return UIEdgeInsetsMake(cellTopToBubbleTop,otherBubbleOriginX,cellBubbleButtomToCellButtom, 0);
}

- (BOOL)shouldShowAvatar:(YSFMessageModel *)model
{
    return [QYCustomUIConfig sharedInstance].showHeadImage;
}


- (BOOL)shouldShowNickName:(YSFMessageModel *)model{
    YSF_NIMMessage *message = model.message;
    if (message.messageType == YSF_NIMMessageTypeNotification)
    {
        YSF_NIMNotificationType type = [(YSF_NIMNotificationObject *)message.messageObject notificationType];
        if (type == YSF_NIMNotificationTypeTeam) {
            return NO;
        }
    }
    if (model.message.messageType == YSF_NIMMessageTypeTip)
    {
        return NO;
    }
    
    return (!message.isOutgoingMsg && message.session.sessionType == YSF_NIMSessionTypeTeam);
}


- (NSString *)formatedMessage:(YSFMessageModel *)model{
    return [YSFKitUtil formatedMessage:model.message];
}
@end

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
#import "YSFApiDefines.h"
#import "YSFBotForm.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFCellLayoutDefaultConfig

- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)cellWidth{
    id<YSFSessionContentConfig>config = [[YSFSessionContentConfigFactory sharedFacotry] configBy:model.message];
    CGSize contentSize = [config contentSize:cellWidth];
    
    if (model.shouldShowDianZan) {//适配气泡高度低于点赞视图的高度
        CGFloat contentMinHeight = model.dianZanViewSize.height + model.dianZanViewInsets.top + model.dianZanViewInsets.bottom;
        return CGSizeMake(contentSize.width, MAX(contentSize.height, contentMinHeight));
    }
    else {
        return contentSize;
    }
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
    if (model.message.isOutgoingMsg && [model.message hasTrashWords]) {
        UILabel *trashWordsTip = [UILabel new];
        trashWordsTip = [UILabel new];
        trashWordsTip.numberOfLines = 0;
        trashWordsTip.lineBreakMode = NSLineBreakByCharWrapping;
        trashWordsTip.font = [UIFont systemFontOfSize:12.f];
        trashWordsTip.frame = CGRectMake(0, 0, YSFUIScreenWidth - 112, 0);
        trashWordsTip.text = [model.message getTrashWordsTip];
        [trashWordsTip sizeToFit];
        cellBubbleButtomToCellButtom += 10 + trashWordsTip.ysf_frameHeight;
    }
    if ([model.message getMiniAppTimeTip].length > 0) {
        UILabel *tip = [UILabel new];
        tip = [UILabel new];
        tip.numberOfLines = 0;
        tip.lineBreakMode = NSLineBreakByCharWrapping;
        tip.font = [UIFont systemFontOfSize:12.f];
        tip.frame = CGRectMake(0, 0, YSFUIScreenWidth - 112, 0);
        tip.text = [model.message getMiniAppTimeTip];
        [tip sizeToFit];
        cellBubbleButtomToCellButtom += 10 + tip.ysf_frameHeight;
    }
    
    if (model.message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = model.message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFBotForm class]]) {
            if (!((YSFBotForm *)customObject.attachment).submitted) {
                cellBubbleButtomToCellButtom += 42;
            }
        }
    }
    
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

- (BOOL)shouldShowDianZan:(YSFMessageModel *)model
{
    YSF_NIMMessage *message = model.message;
    /**
     TODO 七鱼LSP
     新增字段判断是否显示点赞视图
     */
    
    return (!message.isOutgoingMsg && (model.message.messageType == YSF_NIMMessageTypeCustom));
}

- (NSString *)formatedMessage:(YSFMessageModel *)model{
    return [YSFKitUtil formatedMessage:model.message];
}
@end

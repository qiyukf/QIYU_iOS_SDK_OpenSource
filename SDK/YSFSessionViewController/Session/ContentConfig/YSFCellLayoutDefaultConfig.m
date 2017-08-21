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
    NSString *ext = model.message.ext;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && model.message.messageType == YSF_NIMMessageTypeText &&  model.message.isOutgoingMsg) {
        NSArray *trashWordsArray = [[ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
        if (trashWordsArray.count > 0) {
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


- (NSString *)formatedMessage:(YSFMessageModel *)model{
    return [YSFKitUtil formatedMessage:model.message];
}
@end

//
//  YSF_NIMMessage+http.m
//  QYKF
//
//  Created by 金华 on 16/3/22.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSF_NIMMessage+YSF.h"
#import "NSDictionary+YSFJson.h"
#import "YSFNotification.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSF.h"
#import "YSFWelcome.h"
#import "YSFCommodityInfoShow.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFEvaluationTipObject.h"
#import "YSFStartServiceObject.h"
#import "YSFMachineResponse.h"
#import "YSFReportQuestion.h"
#import "YSFKFBypassNotification.h"
#import "YSFRichText.h"

@implementation YSF_NIMMessage (YSF)

- (NSString *)notificationMessageContent:(YSF_NIMMessage *)lastMessage{
    YSF_NIMNotificationObject *object = lastMessage.messageObject;
    if (object.notificationType == YSF_NIMNotificationTypeNetCall) {
        YSF_NIMNetCallNotificationContent *content = (YSF_NIMNetCallNotificationContent *)object.content;
        if (content.callType == YSF_NIMNetCallTypeAudio) {
            return @"[网络通话]";
        }
        return @"[视频聊天]";
    }
    
    return @"[未知消息]";
}

- (NSString *)getDisplayMessageContent{
    NSString *text = @"";
    switch (self.messageType) {
        case YSF_NIMMessageTypeText:
            text = self.text;
            if (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.isOutgoingMsg) {
                text = [self getTextWithoutTrashWords];
            }
            if (![YSF_NIMSDK sharedSDK].sdkOrKf && text.length == 0) {
                text = @"用户进入";
            }
            break;
        case YSF_NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case YSF_NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case YSF_NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case YSF_NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case YSF_NIMMessageTypeNotification:
            text = [self notificationMessageContent:self];
            break;
        case YSF_NIMMessageTypeFile:
        {
            YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)self.messageObject;
            text = [NSString stringWithFormat:@"[文件][%@]", fileObject.displayName];
            break;
        }
        case YSF_NIMMessageTypeCustom:
        {
            NSDictionary *dict = [self.rawAttachContent ysf_toDict];
            if (dict) {
                NSInteger command = [(NSDictionary *)dict ysf_jsonInteger:YSFApiKeyCmd];
                if (command == YSFCommandBotReceive || command == YSFCommandBotSend) {
                    text = @"[查询消息]";
                    break;
                }
            }
            
            YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.messageObject;
            id<YSF_NIMCustomAttachment> attachment = object.attachment;
            if ([attachment isMemberOfClass:[YSFNotification class]]) {
                YSFNotification *notification = attachment;
                text = [NSString stringWithFormat:@"[%@]", notification.message];
            }
            else if ([attachment isMemberOfClass:[YSFWelcome class]]) {
                YSFWelcome *notification = attachment;
                text = [NSString stringWithFormat:@"[%@]", notification.welcome];
            }
//            else if ([attachment isMemberOfClass:[YSFCommodityInfoShow class]])
//            {
//                YSFCommodityInfoShow *commodityInfoShow = attachment;
//                text = [NSString stringWithFormat:@"%@", commodityInfoShow.urlString];
//            }
            else if ([attachment isMemberOfClass:[YSFCommodityInfoShow class]])
            {
                text = @"发送了一条消息";
            }
            else if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]])
            {
                text = @"感谢您的咨询，请对我们的服务作出评价";
            }
            else if ([attachment isMemberOfClass:[YSFEvaluationTipObject class]])
            {
                YSFEvaluationTipObject *evaluationTipObject = attachment;
                text = [NSString stringWithFormat:@"[%@%@]", evaluationTipObject.tipContent, evaluationTipObject.tipResult];
            }
            else if ([attachment isMemberOfClass:[YSFStartServiceObject class]])
            {
                YSFStartServiceObject *startServiceObject = attachment;
                text = [NSString stringWithFormat:@"[客服%@为您服务]", startServiceObject.staffName];
            }
            else if ([attachment isMemberOfClass:[YSFMachineResponse class]])
            {
                YSFMachineResponse *machineResponse = attachment;
                if (machineResponse.operatorHint) {
                    text = [NSString stringWithFormat:@"%@", machineResponse.operatorHintDesc];
                }
                else {
                    text = [NSString stringWithFormat:@"%@", machineResponse.answerLabel];
                    for (NSDictionary *item in machineResponse.answerArray) {
                        NSString *answerText = item[@"answer"] ? : @"";
                        text = [text stringByAppendingString:answerText];
                    }
                }
                
            }
            else if ([attachment isMemberOfClass:[YSFReportQuestion class]])
            {
                YSFReportQuestion *reportQuestion = attachment;
                text = [NSString stringWithFormat:@"%@", reportQuestion.question];
            }
            else if ([attachment isMemberOfClass:[YSFKFBypassNotification class]])
            {
                YSFKFBypassNotification *kfBypassNotification = attachment;
                text = [NSString stringWithFormat:@"[%@:", kfBypassNotification.message];
                NSInteger index = 0;
                for (NSDictionary *item in kfBypassNotification.entries) {
                    NSString *labelText = item[@"label"] ? : @"";
                    if (index != kfBypassNotification.entries.count - 1) {
                        text = [text stringByAppendingFormat:@"%@ / ", labelText];
                    }
                    else {
                        text = [text stringByAppendingFormat:@"%@]", labelText];
                    }
                    index++;
                }
            }
            else if ([attachment isMemberOfClass:[YSFRichText class]])
            {
                text = ((YSFRichText *)attachment).displayContent;
            }
            else {
                text = @"[未知消息]";
            }
        }
            break;
        default:
            text = @"[未知消息]";
    }
    
    return text;
}

- (NSString *)getTextWithoutTrashWords
{
    NSString *text = self.text;
    NSArray *trashWordsArray = [[self.ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
    trashWordsArray = [trashWordsArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.length > obj2.length) {
            return NSOrderedAscending;
        }
        else if (obj1.length == obj2.length) {
            return NSOrderedSame;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    for (NSString *transhWords in trashWordsArray) {
        NSString *replaceStr = @"";
        for (int i = 0; i < transhWords.length; i++) {
            replaceStr = [replaceStr stringByAppendingString:@"*"];
        }
        text = [text stringByReplacingOccurrencesOfString:transhWords withString:replaceStr];
    }
    
    return text;
}

- (BOOL)hasTrashWords
{
    NSArray *trashWordsArray = [[self.ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
    return trashWordsArray.count > 0;
}

- (NSString *)getTrashWordsTip
{
    NSString *tip = @"";
    NSString *ext = self.ext;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && self.isOutgoingMsg) {
        NSArray *trashWordsArray = [[ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
        if (trashWordsArray.count > 0) {
            tip = @"消息包含违禁词“";
            int totalWords = 10;
            for (int i = 0; i < trashWordsArray.count; i++) {
                NSString *trashWords = trashWordsArray[i];
                totalWords -= trashWords.length;
                if (totalWords < 0) {
                    trashWords = [trashWords substringToIndex:(trashWords.length + totalWords)];
                    trashWords = [trashWords stringByAppendingString:@"..."];
                }
                if (i != 0) {
                    tip = [tip stringByAppendingString:@"，"];
                }
                tip = [tip stringByAppendingString:trashWords];
                if (i == trashWordsArray.count - 1) {
                    tip = [tip stringByAppendingString:@"”，发送失败"];
                }
                
                if (totalWords <= 0) {
                    break;
                }
            }
        }
        
    }
        
    return tip;
}




@end


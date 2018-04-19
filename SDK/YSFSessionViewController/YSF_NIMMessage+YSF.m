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
#import "YSFTrashWords.h"

@implementation YSF_NIMMessage (YSF)

//- (NSString *)notificationMessageContent:(YSF_NIMMessage *)lastMessage{
//    YSF_NIMNotificationObject *object = lastMessage.messageObject;
//    if (object.notificationType == YSF_NIMNotificationTypeNetCall) {
////        YSF_NIMNetCallNotificationContent *content = (YSF_NIMNetCallNotificationContent *)object.content;
////        if (content.callType == YSF_NIMNetCallTypeAudio) {
////            return @"[网络通话]";
////        }
//        return @"[视频聊天]";
//    }
//
//    return @"[未知消息]";
//}

//        case YSF_NIMMessageTypeNotification:
//            text = [self notificationMessageContent:self];
//            break;

- (NSString *)thumbText
{
    NSString *thumbText = @"";
    if (self.messageType == YSF_NIMMessageTypeText) {
        NSString *text = self.text;
        if (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.isOutgoingMsg) {
            text = [self getTextWithoutTrashWords];
        }
        if (![YSF_NIMSDK sharedSDK].sdkOrKf && text.length == 0) {
            text = @"用户进入";
        }
        thumbText = text;
    }
    else if (self.messageType == YSF_NIMMessageTypeTip) {
        thumbText = [NSString stringWithFormat:@"[%@]", self.text];
    }
    else {
        if ([self.messageObject respondsToSelector:@selector(thumbText)]) {
            thumbText = [self.messageObject thumbText];
        }
        else {
            thumbText = @"[未知消息]";
        }
    }
    
    return thumbText;
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
    YSFAuditResultType auditResultType = [[self.ext ysf_toDict] ysf_jsonInteger:YSFApiKeyAuditResult];
    NSArray *trashWordsArray = [[self.ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
    
    //旧版本没有auditResultType
    return auditResultType != YSFAuditResultTypeOK || trashWordsArray.count > 0;
}

- (NSString *)getTrashWordsTip
{
    NSString *tip = @"";
    NSString *ext = self.ext;
    if (self.isOutgoingMsg) {
        //旧版本没有auditResultType
        NSArray *trashWordsArray = [[ext ysf_toDict] ysf_jsonArray:YSFApiKeyTrashWords];
        YSFAuditResultType andiResultType = [[ext ysf_toDict] ysf_jsonInteger:YSFApiKeyAuditResult];
        if (andiResultType == YSFAuditResultTypeYidun) {
            tip = @"消息包含违禁信息，发送失败";
        }
        else if (trashWordsArray.count > 0) {
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


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
                if (command == YSFCommandBot || command == YSFCommandBotSelection) {
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
        }
            break;
        default:
            text = @"[未知消息]";
    }
    
    return text;
}

@end


//
//  YSF_NIMUtil.m
//  YSFKit
//
//  Created by chris on 15/8/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFKitUtil.h"
#import "YSFKit.h"

@implementation YSFKitUtil

+ (NSString *)showNick:(NSString*)uid inSession:(YSF_NIMSession*)session{
    return @"";
//    YSF_NIMSessionType sessionType = session.sessionType;
//    NSString *sessionId = session.sessionId;
//    
//    if (sessionType == YSF_NIMSessionTypeYSF)
//    {
//        if (uid && sessionId && [uid isEqualToString:sessionId])
//        {
//            return [[[YSFKit sharedKit] infoByService:uid] showName];
//        }
//        else
//        {
//            return [[[YSFKit sharedKit] infoByCustomer:uid] showName];
//        }
//    }
//    else
//    {
//        NSString *nickname = nil;
//        if (session.sessionType == YSF_NIMSessionTypeTeam)
//        {
//            YSF_NIMTeamMember *member = [[YSF_NIMSDK sharedSDK].teamManager teamMember:uid
//                                                                        inTeam:sessionId];
//            nickname = member.nickname;
//        }
//        if (!nickname.length) {
//            YSFSessionUserInfo *info = [[YSFKit sharedKit] infoByCustomer:uid];
//            nickname = info.showName;
//        }
//        return nickname;
//    }
    
}
+ (NSString*)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    NSDate *today = [[NSDate alloc] init];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSDateComponents *yesterdayDateComponents = [[NSCalendar currentCalendar] components:components fromDate:yesterday];

    NSInteger hour = msgDateComponents.hour;
    result = @"";
    
    if(nowDateComponents.year == msgDateComponents.year
       && nowDateComponents.month == msgDateComponents.month
       && nowDateComponents.day == msgDateComponents.day) //今天,hh:mm
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(yesterdayDateComponents.year == msgDateComponents.year
            && yesterdayDateComponents.month == msgDateComponents.month
            && yesterdayDateComponents.day == msgDateComponents.day)//昨天，昨天 hh:mm
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"昨天";
    }
    else if(nowDateComponents.year == msgDateComponents.year)//今年，MM/dd hh:mm
    {
//        NSString *weekDay = [YSFKitUtil weekdayStr:msgDateComponents.weekday];
        result = [NSString stringWithFormat:@"%02d/%02d %zd:%02d",(int)msgDateComponents.month,(int)msgDateComponents.day,msgDateComponents.hour,(int)msgDateComponents.minute];
    }
    else if((nowDateComponents.year != msgDateComponents.year))//跨年， YY/MM/dd hh:mm
    {
        NSString *day = [NSString stringWithFormat:@"%02d/%02d/%02d", (int)(msgDateComponents.year%100), (int)msgDateComponents.month, (int)msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@" %@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

#pragma mark - Private

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨";
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午";
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午";
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上";
    }
    return showPeriodOfTime;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日",
                       @(2):@"星期一",
                       @(3):@"星期二",
                       @(4):@"星期三",
                       @(5):@"星期四",
                       @(6):@"星期五",
                       @(7):@"星期六",};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}


+ (NSString *)formatedMessage:(YSF_NIMMessage *)message{
    switch (message.messageType) {
        case YSF_NIMMessageTypeNotification:
            return [YSFKitUtil notificationMessage:message];
        case YSF_NIMMessageTypeTip:
            return message.text;
        default:
            break;
    }
    return nil;
}


+ (NSString *)notificationMessage:(YSF_NIMMessage *)message{
    YSF_NIMNotificationObject *object = message.messageObject;
    switch (object.notificationType) {
//        case YSF_NIMNotificationTypeTeam:{
//            return [YSFKitUtil teamNotificationFormatedMessage:message];
//        }
//        case YSF_NIMNotificationTypeNetCall:{
//            return [YSFKitUtil netcallNotificationFormatedMessage:message];
//        }
        default:
            return @"";
    }
}


//+ (NSString*)teamNotificationFormatedMessage:(YSF_NIMMessage *)message{
//    NSString *formatedMessage = @"";
//    YSF_NIMNotificationObject *object = message.messageObject;
//    if (object.notificationType == YSF_NIMNotificationTypeTeam)
//    {
//        YSF_NIMTeamNotificationContent *content = (YSF_NIMTeamNotificationContent*)object.content;
//        NSString *currentAccount = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
//        NSString *source;
//        if ([content.sourceID isEqualToString:currentAccount]) {
//            source = @"你";
//        }else{
//            source = [YSFKitUtil showNick:content.sourceID inSession:message.session];
//        }
//        NSMutableArray *targets = [[NSMutableArray alloc] init];
//        for (NSString *item in content.targetIDs) {
//            if ([item isEqualToString:currentAccount]) {
//                [targets addObject:@"你"];
//            }else{
//                NSString *targetShowName = [YSFKitUtil showNick:item inSession:message.session];
//                [targets addObject:targetShowName];
//            }
//        }
//        NSString *targetText = [targets count] > 1 ? [targets componentsJoinedByString:@","] : [targets firstObject];
//        switch (content.operationType) {
//            case YSF_NIMTeamOperationTypeInvite:{
//                NSString *str = [NSString stringWithFormat:@"%@邀请%@",source,targets.firstObject];
//                if (targets.count>1) {
//                    str = [str stringByAppendingFormat:@"等%zd人",targets.count];
//                }
//                str = [str stringByAppendingFormat:@"进入了群聊"];
//                formatedMessage = str;
//            }
//                break;
//            case YSF_NIMTeamOperationTypeDismiss:
//                formatedMessage = [NSString stringWithFormat:@"%@解散了群聊",source];
//                break;
//            case YSF_NIMTeamOperationTypeKick:{
//                NSString *str = [NSString stringWithFormat:@"%@将%@",source,targets.firstObject];
//                if (targets.count>1) {
//                    str = [str stringByAppendingFormat:@"等%zd人",targets.count];
//                }
//                str = [str stringByAppendingFormat:@"移出了群聊"];
//                formatedMessage = str;
//            }
//                break;
//            case YSF_NIMTeamOperationTypeUpdate:
//            {
//                id attachment = [content attachment];
//                if ([attachment isKindOfClass:[YSF_NIMUpdateTeamInfoAttachment class]]) {
//                    YSF_NIMUpdateTeamInfoAttachment *teamAttachment = (YSF_NIMUpdateTeamInfoAttachment *)attachment;
//                    //如果只是单个项目项被修改则显示具体的修改项
//                    if ([teamAttachment.values count] == 1) {
//                        YSF_NIMTeamUpdateTag tag = [[[teamAttachment.values allKeys] firstObject] integerValue];
//                        switch (tag) {
//                            case YSF_NIMTeamUpdateTagName:
//                                formatedMessage = [NSString stringWithFormat:@"%@更新了群名称",source];
//                                break;
//                            case YSF_NIMTeamUpdateTagIntro:
//                                formatedMessage = [NSString stringWithFormat:@"%@更新了群介绍",source];
//                                break;
//                            case YSF_NIMTeamUpdateTagAnouncement:
//                                formatedMessage = [NSString stringWithFormat:@"%@更新了群公告",source];
//                                break;
//                            case YSF_NIMTeamUpdateTagJoinMode:
//                                formatedMessage = [NSString stringWithFormat:@"%@更新了群验证方式",source];
//                                break;
//                            default:
//                                break;
//
//                        }
//                    }
//                }
//                if (formatedMessage == nil){
//                    formatedMessage = [NSString stringWithFormat:@"%@更新了群信息",source];
//                }
//            }
//                break;
//            case YSF_NIMTeamOperationTypeLeave:
//                formatedMessage = [NSString stringWithFormat:@"%@离开了群聊",source];
//                break;
//            case YSF_NIMTeamOperationTypeApplyPass:{
//                if ([source isEqualToString:targetText]) {
//                    //说明是以不需要验证的方式进入
//                    formatedMessage = [NSString stringWithFormat:@"%@进入了群聊",source];
//                }else{
//                    formatedMessage = [NSString stringWithFormat:@"%@通过了%@的入群申请",source,targetText];
//                }
//            }
//                break;
//            case YSF_NIMTeamOperationTypeTransferOwner:
//                formatedMessage = [NSString stringWithFormat:@"%@转移了群主身份给%@",source,targetText];
//                break;
//            case YSF_NIMTeamOperationTypeAddManager:
//                formatedMessage = [NSString stringWithFormat:@"%@被群主添加为群管理员",targetText];
//                break;
//            case YSF_NIMTeamOperationTypeRemoveManager:
//                formatedMessage = [NSString stringWithFormat:@"%@被群主撤销了群管理员身份",targetText];
//                break;
//            case YSF_NIMTeamOperationTypeAcceptInvitation:
//                formatedMessage = [NSString stringWithFormat:@"%@接受%@的邀请进群",source,targetText];
//                break;
//            default:
//                break;
//        }
//
//    }
//    if (!formatedMessage.length) {
//        formatedMessage = [NSString stringWithFormat:@"未知系统信息"];
//    }
//    return formatedMessage;
//}


//+ (NSString *)netcallNotificationFormatedMessage:(YSF_NIMMessage *)message{
//    YSF_NIMNotificationObject *object = message.messageObject;
//    YSF_NIMNetCallNotificationContent *content = (YSF_NIMNetCallNotificationContent *)object.content;
//    NSString *text = @"";
//    NSString *currentAccount = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
//    switch (content.eventType) {
//        case YSF_NIMNetCallEventTypeMiss:{
//            text = @"未接听";
//            break;
//        }
//        case YSF_NIMNetCallEventTypeBill:{
//            text =  ([object.message.from isEqualToString:currentAccount])? @"通话拨打时长 " : @"通话接听时长 ";
//            NSTimeInterval duration = content.duration;
//            NSString *durationDesc = [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
//            text = [text stringByAppendingString:durationDesc];
//            break;
//        }
//        case YSF_NIMNetCallEventTypeReject:{
//            text = ([object.message.from isEqualToString:currentAccount])? @"对方正忙" : @"已拒绝";
//            break;
//        }
//        case YSF_NIMNetCallEventTypeNoResponse:{
//            text = @"未接通，已取消";
//            break;
//        }
//        default:
//            break;
//    }
//    return text;
//}

@end

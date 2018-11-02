//
//  YSFKitEvent.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFKitEvent.h"

NSString *const YSFKitEventNameReloadData = @"YSFKitEventNameReloadData";
NSString *const YSFKitEventNameTapContent = @"YSFKitEventNameTapContent";
NSString *const YSFKitEventNameTapLabelLink = @"YSFKitEventNameTapLabelLink";
NSString *const YSFKitEventNameTapLabelPhoneNumber = @"YSFKitEventNameTapLabelPhoneNumber";
NSString *const YSFKitEventNameTapMachineQuestion = @"YSFKitEventNameTapMachineQuestion";
NSString *const YSFKitEventNameTapEvaluationSelection = @"YSFKitEventNameTapEvaluationSelection";
NSString *const YSFKitEventNameTapEvaluationReason = @"YSFKitEventNameTapEvaluationReason";
NSString *const YSFKitEventNameTapGoods = @"YSFKitEventNameTapGoods";
NSString *const YSFKitEventNameTapFillInBotForm = @"YSFKitEventNameFillInBotForm";
NSString *const YSFKitEventNameTapMoreOrders = @"YSFKitEventNameTapMoreOrders";
NSString *const YSFKitEventNameTapMoreFlight = @"YSFKitEventNameTapMoreFlight";
NSString *const YSFKitEventNameTapBot = @"YSFKitEventNameTapBot";
NSString *const YSFKitEventNameTapAction = @"YSFKitEventNameTapAction";
NSString *const YSFKitEventNameTapMixReply = @"YSFKitEventNameTapMixReply";
NSString *const YSFKitEventNameTapKFBypass = @"YSFKitEventNameTapKFBypass";
NSString *const YSFKitEventNameTapCommodityInfo = @"YSFKitEventNameTapCommodityInfo";
NSString *const YSFKitEventNameTapEvaluation = @"YSFKitEventNameTapEvaluation";
NSString *const YSFKitEventNameTapModifyEvaluation = @"YSFKitEventNameTapModifyEvaluation";
NSString *const YSFKitEventNameTapRetryAudioToText = @"YSFKitEventNameTapRetryAudioToText";
NSString *const YSFKitEventNameTapRichTextImage = @"YSFKitEventNameTapRichTextImage";
NSString *const YSFKitEventNameTapPushMessageActionUrl = @"YSFKitEventNameTapPushMessageActionUrl";
NSString *const YSFKitEventNameOpenUrl = @"YSFKitEventNameOpenUrl";
NSString *const YSFKitEventNameSendCommdityInfo = @"YSFKitEventNameSendMessage";
NSString *const YSFKitEventNameTapCommdityAction = @"YSFKitEventNameTapCommdityAction";
NSString *const YSFKitEventNameTapExtraViewAction = @"YSFKitEventNameTapExtraViewAction";
NSString *const YSFKitEventNameTapSystemNotification = @"YSFKitEventNameTapSystemNotification";

@implementation YSFKitEvent

- (NSString *)transferEventNameForExternal {
    if (self.eventName.length) {
        return [self.eventName stringByReplacingOccurrencesOfString:@"YSFKit" withString:@"QY"];
    }
    return @"";
}

@end

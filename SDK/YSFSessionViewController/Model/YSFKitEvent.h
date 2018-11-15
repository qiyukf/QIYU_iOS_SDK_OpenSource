//
//  YSFKitEvent.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//


@interface YSFKitEvent : NSObject

@property (nonatomic,copy) NSString *eventName;

@property (nonatomic,strong) YSF_NIMMessage *message;

@property (nonatomic,strong) id data;

- (NSString *)transferEventNameForExternal;

@end


extern NSString *const YSFKitEventNameReloadData;
extern NSString *const YSFKitEventNameTapContent;
extern NSString *const YSFKitEventNameTapLabelLink;
extern NSString *const YSFKitEventNameTapLabelPhoneNumber;
extern NSString *const YSFKitEventNameTapMachineQuestion;
extern NSString *const YSFKitEventNameTapEvaluationSelection;
extern NSString *const YSFKitEventNameTapEvaluationReason;
extern NSString *const YSFKitEventNameTapGoods;
extern NSString *const YSFKitEventNameTapFillInBotForm;
extern NSString *const YSFKitEventNameTapMoreOrders;
extern NSString *const YSFKitEventNameTapMoreFlight;
extern NSString *const YSFKitEventNameTapBot;
extern NSString *const YSFKitEventNameTapAction;
extern NSString *const YSFKitEventNameTapMixReply;
extern NSString *const YSFKitEventNameTapKFBypass;
extern NSString *const YSFKitEventNameTapCommodityInfo;
extern NSString *const YSFKitEventNameTapEvaluation;
extern NSString *const YSFKitEventNameTapModifyEvaluation;
extern NSString *const YSFKitEventNameTapRetryAudioToText;
extern NSString *const YSFKitEventNameTapRichTextImage;
extern NSString *const YSFKitEventNameTapSubmittedBotFormImage;
extern NSString *const YSFKitEventNameTapPushMessageActionUrl;
extern NSString *const YSFKitEventNameOpenUrl;
extern NSString *const YSFKitEventNameSendCommdityInfo;
extern NSString *const YSFKitEventNameTapCommdityAction;
extern NSString *const YSFKitEventNameTapExtraViewAction;
extern NSString *const YSFKitEventNameTapSystemNotification;

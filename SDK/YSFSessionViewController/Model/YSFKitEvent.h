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

@end


extern NSString *const YSFKitEventNameTapContent;
extern NSString *const YSFKitEventNameTapLabelLink;
extern NSString *const YSFKitEventNameTapLabelPhoneNumber;
extern NSString *const YSFKitEventNameTapMachineQuestion;
extern NSString *const YSFKitEventNameTapMachineManual;
extern NSString *const YSFKitEventNameTapKFBypass;
extern NSString *const YSFKitEventNameTapCommodityInfo;
extern NSString *const YSFKitEventNameTapEvaluation;
extern NSString *const YSFKitEventNameTapRetryAudioToText;

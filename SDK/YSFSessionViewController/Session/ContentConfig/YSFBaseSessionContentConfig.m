//
//  NIMBaseSessionContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFBaseSessionContentConfig.h"
#import "YSFTextContentConfig.h"
#import "YSFImageContentConfig.h"
#import "YSFAudioContentConfig.h"
#import "YSFVideoContentConfig.h"
#import "YSFFileContentConfig.h"
#import "YSFLocationContentConfig.h"
#import "YSFUnsupportContentConfig.h"
#import "YSFMachineResponse.h"
#import "YSFMachineContentConfig.h"
#import "YSFNewSession.h"
#include "YSFSessionClose.h"
#import "YSFWelcome.h"
#import "YSFReportQuestion.h"
#import "YSFKFBypassContentConfig.h"
#import "YSFKFBypassNotification.h"
#import "YSFCommodityInfoContentConfig.h"
#import "YSFCommodityInfoShow.h"
#import "YSFInviteEvaluationObject.h"



@implementation YSFBaseSessionContentConfig
@end


@interface YSFSessionContentConfigFactory ()
@property (nonatomic,strong)    NSDictionary                *dict;
@end

@implementation YSFSessionContentConfigFactory

+ (instancetype)sharedFacotry
{
    static YSFSessionContentConfigFactory *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFSessionContentConfigFactory alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _dict = @{@(YSF_NIMMessageTypeText)         :       [YSFTextContentConfig new],
                  @(YSF_NIMMessageTypeImage)        :       [YSFImageContentConfig new],
                  @(YSF_NIMMessageTypeAudio)        :       [YSFAudioContentConfig new],
                  @(YSF_NIMMessageTypeVideo)        :       [YSFVideoContentConfig new],
                  @(YSF_NIMMessageTypeFile)         :       [YSFFileContentConfig new],
                  @(YSF_NIMMessageTypeLocation)     :       [YSFLocationContentConfig new]};
    }
    return self;
}

- (id<YSFSessionContentConfig>)configBy:(YSF_NIMMessage *)message
{
    YSF_NIMMessageType type = message.messageType;
    id<YSFSessionContentConfig>config = [_dict objectForKey:@(type)];
    if (config == nil) {
        if (type == YSF_NIMMessageTypeCustom) {
            YSF_NIMCustomObject *customObject = message.messageObject;
            if ([customObject.attachment isKindOfClass:[YSFMachineResponse class]]) {
                config = [[YSFMachineContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
                config = [[YSFKFBypassContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFNewSession class]]) {
                config = [[YSFTextContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFSessionClose class]]) {
                config = [[YSFTextContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFWelcome class]]) {
                YSFWelcome *welcome = (YSFWelcome *)customObject.attachment;
                message.text = welcome.welcome;
                config = [[YSFTextContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]) {
                YSFReportQuestion *reportQuestion = (YSFReportQuestion *)customObject.attachment;
                message.text = reportQuestion.question;
                config = [[YSFTextContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFCommodityInfoShow class]]){
                config = [[YSFCommodityInfoContentConfig alloc] init];
            }
        }
    }
    if (config == nil)
    {
        config = [YSFUnsupportContentConfig sharedConfig];
    }
    if ([config isKindOfClass:[YSFBaseSessionContentConfig class]])
    {
        [(YSFBaseSessionContentConfig *)config setMessage:message];
    }
    return config;
}

@end
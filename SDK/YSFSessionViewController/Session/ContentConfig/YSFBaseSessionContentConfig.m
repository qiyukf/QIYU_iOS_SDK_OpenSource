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
#import "YSFSessionClose.h"
#import "YSFWelcome.h"
#import "YSFReportQuestion.h"
#import "YSFKFBypassContentConfig.h"
#import "YSFKFBypassNotification.h"
#import "YSFCommodityInfoContentConfig.h"
#import "YSFCommodityInfoShow.h"
#import "YSFOrderList.h"
#import "YSFOrderListContentConfig.h"
#import "YSFBotText.h"
#import "YSFSelectedGoods.h"
#import "YSFSelectedGoodsContentConfig.h"
#import "YSFOrderStatus.h"
#import "YSFOrderStatusContentConfig.h"
#import "YSFOrderLogistic.h"
#import "YSFOrderLogisticContentConfig.h"
#import "YSFOrderOperation.h"
#import "YSFOrderDetail.h"
#import "YSFOrderDetailContentConfig.h"
#import "YSFRefundDetail.h"
#import "YSFRefundDetailContentConfig.h"
#import "YSFActionList.h"
#import "YSFActionListContentConfig.h"
#import "YSFActivePage.h"
#import "YSFActivePageContentConfig.h"
#import "YSFRichTextContentConfig.h"
#import "YSFRichText.h"
#import "YSFBotForm.h"
#import "YSFBotFormContentConfig.h"
#import "YSFSubmittedBotForm.h"
#import "YSFSubmittedBotFormContentConfig.h"
#import "YSFStaticUnion.h"
#import "YSFStaticUnionContentConfig.h"
#import "YSFFlightList.h"
#import "YSFFlightListContentConfig.h"
#import "YSFFlightDetail.h"
#import "YSFCustomAttachment.h"


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
    id<YSFSessionContentConfig> config = nil;
    if (_queryCustomContentConifgBlock) {
        config = _queryCustomContentConifgBlock(message);
    }
    if (config) {
        return config;
    }
    
    YSF_NIMMessageType type = message.messageType;
    config = [_dict objectForKey:@(type)];
    if (config == nil) {
        if (type == YSF_NIMMessageTypeCustom) {
            YSF_NIMCustomObject *customObject = message.messageObject;
            if ([customObject.attachment isKindOfClass:[YSFOrderOperation class]]) {
                YSFOrderOperation *orderOperation = (YSFOrderOperation *)customObject.attachment;
                message.text = [orderOperation.template ysf_jsonString:@"label"];
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
            else if ([customObject.attachment isKindOfClass:[YSFBotText class]]) {
                YSFBotText *botText = (YSFBotText *)customObject.attachment;
                message.text = botText.text;
                config = [[YSFTextContentConfig alloc] init];
            }
            else if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]) {
                YSFReportQuestion *reportQuestion = (YSFReportQuestion *)customObject.attachment;
                message.text = reportQuestion.question;
                config = [[YSFTextContentConfig alloc] init];
            }
            
            if (!config && [customObject.attachment respondsToSelector:@selector(contentConfig)]) {
                config = [(id<YSFCustomAttachment>)(customObject.attachment) contentConfig];
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

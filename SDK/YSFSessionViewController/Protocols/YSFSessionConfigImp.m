//
//  YSFSessionConfigImp.m
//  YSFSDK
//
//  Created by amao on 9/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFSessionConfigImp.h"
#import "YSFStartServiceObject.h"
#import "YSFNotificationCellLayoutConfig.h"
#import "YSFMachineResponse.h"
#import "YSFEvaluationTipObject.h"
#import "YSFNotification.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFInviteEvaluationCellLayoutConfig.h"


@implementation YSFSessionConfigImp
- (id<YSFCellLayoutConfig>)layoutConfigWithMessage:(YSF_NIMMessage *)message
{
    id layoutConfig = nil;
    id object = message.messageObject;
    if ([object isKindOfClass:[YSF_NIMCustomObject class]])
    {
        id attachment = [(YSF_NIMCustomObject *)object attachment];
        if ([attachment isKindOfClass:[YSFStartServiceObject class]]
            || [attachment isKindOfClass:[YSFEvaluationTipObject class]]
            || [attachment isKindOfClass:[YSFNotification class]])
        {
            layoutConfig =  [YSFNotificationCellLayoutConfig new];
        }
        else if ([attachment isKindOfClass:[YSFInviteEvaluationObject class]])
        {
            layoutConfig =  [YSFInviteEvaluationCellLayoutConfig new];
        }
    }
    return layoutConfig;
}

@end

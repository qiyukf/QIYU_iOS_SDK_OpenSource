//
//  YSFIMRespParser.m
//  YSFSDK
//
//  Created by amao on 9/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFCustomSystemNotificationParser.h"
#import "NSDictionary+YSFJson.h"
#import "YSFServiceSession.h"
#import "YSFCloseServiceNotification.h"
#import "YSFQueryWaitingStatus.h"
#import "YSFApiDefines.h"
#import "YSFKFBypassNotification.h"
#import "YSFSessionStatusResponse.h"


@implementation YSFCustomSystemNotificationParser

+ (id)parse:(NSString *)content
{
    id result = nil;
    if (content) {
        NSDictionary *dict = [content ysf_toDict];
        if (dict) {
            NSInteger cmd = [dict ysf_jsonInteger:YSFApiKeyCmd];
            switch (cmd) {
                case YSFCommandRequestServiceResponse:
                    result = [YSFServiceSession dataByJson:dict];
                    break;
                case YSFCommandCloseServiceRequest:
                    result = [YSFCloseServiceNotification dataByJson:dict];
                    break;
                case YSFCommandWaitingStatusResponse:
                    result = [YSFQueryWaitingStatusResponse dataByJson:dict];
                    break;
                case YSFCommandKFBypassNotification:
                    result = [YSFKFBypassNotification dataByJson:dict];
                    break;
                case YSFCommandSessionStatusResponse:
                    result = [YSFSessionStatusResponse dataByJson:dict];
                    break;
                default:
                    NSAssert(0, @"command not supported %zd",cmd);
                    NIMLogErr(@"command not supported %zd",cmd);
                    break;
            }
        }
    }
    return result;
}

@end

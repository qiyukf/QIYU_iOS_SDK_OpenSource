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
#import "YSFUploadLog.h"
#import "YSFServerSetting.h"
#import "YSFBotQueryResponse.h"
#import "YSFEvaluationNotification.h"
#import "YSFSessionWillCloseNotification.h"


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
                case YSFCommandCloseSessionNotification:
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
                case YSFCommandBotQueryResponse:
                    result = [YSFBotQueryResponse dataByJson:dict];
                    break;
                case YSFCommandEvaluationNotification:
                    result = [YSFEvaluationNotification dataByJson:dict];
                    break;
                case YSFCommandSessionWillClose:
                    result = [YSFSessionWillCloseNotification dataByJson:dict];
                    break;
                case YSFCommandUploadLog:
                {
                    YSFUploadLog *uploadLog = [[YSFUploadLog alloc] init];
                    uploadLog.apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
                    uploadLog.version = @"sdk_3.5.5";
                    uploadLog.type = @"invite";
                    uploadLog.message = YSF_GetMessage(1000000);
                    uploadLog.time = [[NSDate date] timeIntervalSince1970] * 1000;
                    [YSFHttpApi post:uploadLog
                          completion:^(NSError *error, id returendObject) {
                              
                          }];
                    
                }
                    break;
                    
                default:
                    break;
                    
            }
        }
    }
    return result;
}

@end

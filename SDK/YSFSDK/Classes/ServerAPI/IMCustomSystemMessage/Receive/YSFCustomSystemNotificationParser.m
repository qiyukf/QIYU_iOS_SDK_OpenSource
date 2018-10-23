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
#import "YSFSystemConfig.h"
#import "YSFTrashWords.h"
#import "YSFLongMessage.h"
#import "YSFSendSearchQuestionResponse.h"
#import "YSFSearchQuestionSetting.h"
#import "YSFBotEntry.h"
#import "YSFRevokeMessageResult.h"
#import "QYSDK_Private.h"

@implementation YSFCustomSystemNotificationParser

+ (id)parse:(NSString *)content shopId:(NSString *)shopId
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
                case YSFCommandSystemConfig:
                    result = [[YSFSystemConfig sharedInstance:shopId] setNewConfig:dict];
                    break;
                case YSFCommandTrashWords:
                    result = [YSFTrashWords dataByJson:dict];
                    break;
                case YSFCommandLongMessage:
                    result = [YSFLongMessage dataByJson:dict];
                    break;
                case YSFCommandSearchQuestiongResponse:
                    result = [YSFSendSearchQuestionResponse dataByJson:dict];
                    break;
                case YSFCommandSearchQuestiongSetting:
                    [[YSFSearchQuestionSetting sharedInstance:shopId] dataByJson:dict];
                    break;
                case YSFCommandBotEntry:
                    result = [YSFBotEntry dataByJson:dict];
                    break;
                case YSFCommandRevokeMessageResult:
                    result = [YSFRevokeMessageResult dataByJson:dict];
                    break;
                case YSFCommandUploadLog: {
                    YSFUploadLog *uploadLog = [[YSFUploadLog alloc] init];
                    uploadLog.version = [[QYSDK sharedSDK].infoManager version];
                    uploadLog.type = YSFUploadLogTypeInvite;
                    uploadLog.logString = YSF_GetMessage(50000);
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

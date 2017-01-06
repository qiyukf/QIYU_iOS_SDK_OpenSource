//
//  YSFCustomObjectParser.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFCustomObjectParser.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "YSFStartServiceObject.h"
#import "YSFMachineResponse.h"
#import "YSFEvaluationTipObject.h"
#import "YSFNewSession.h"
#import "YSFWelcome.h"
#import "YSFSessionClose.h"
#import "YSFNotification.h"
#import "YSFKFBypassNotification.h"
#import "YSFReportQuestion.h"
#import "YSFCommodityInfoShow.h"
#import "YSFInviteEvaluationObject.h"

@implementation YSFCustomObjectParser
- (id<YSF_NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id object = nil;
    NSDictionary *dict = [content ysf_toDict];
    if (dict) {
        NSInteger command = [(NSDictionary *)dict ysf_jsonInteger:YSFApiKeyCmd];
        switch (command) {
            case YSFCommandRequestServiceResponse:
                object = [YSFStartServiceObject objectByDict:dict];
                break;
            case YSFCommandMachine:
                object = [YSFMachineResponse objectByDict:dict];
                break;
            case YSFCommandEvaluationTip:
                object = [YSFEvaluationTipObject objectByDict:dict];
                break;
            case YSFCommandInviteEvaluation:
                object = [YSFInviteEvaluationObject objectByDict:dict];
                break;
            case YSFCommandSetCommodityInfoRequest:
                object = [YSFCommodityInfoShow objectByDict:dict];
                break;
            
            //移动工作台
            case YSFCommandNewSession:
            {
                YSFNotification *notification = [YSFNotification new];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandNewSession;
                notification.message = @"用户进入";
                object = notification;
            }
                break;
            case YSFCommandWelcome:
                object = [YSFWelcome objectByDict:dict];
                break;
            case YSFCommandSessionClose:
            {
                YSFSessionClose *sessionClose = [YSFSessionClose objectByDict:dict];
                YSFNotification *notification = [YSFNotification new];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandSessionClose;
                notification.message = sessionClose.message;
                object = notification;
            }
                break;
            case YSFCommandCloseServiceResponse:
            {
                YSFNotification *notification = [YSFNotification new];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandCloseServiceResponse;
                notification.message = @"客服关闭";
                object = notification;
            }
                break;
            case YSFCommandNotification:
                object = [YSFNotification objectByDict:dict];
                break;
            case YSFCommandKFBypassNotification:
                object = [YSFKFBypassNotification objectByDict:dict];
                break;
            case YSFCommandReportQuestion:
                object = [YSFReportQuestion objectByDict:dict];
                break;
            default:
                NSAssert(0, @"%zd not supported",command);
                NIMLogErr(@"%zd not supported",command);

                break;
        }
    }
    
    return object;
}
@end

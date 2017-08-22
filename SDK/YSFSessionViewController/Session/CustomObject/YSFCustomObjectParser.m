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
#import "NSDictionary+YSFJson.h"
#import "YSFOrderList.h"
#import "YSFOrderLogistic.h"
#import "YSFOrderStatus.h"
#import "YSFOrderDetail.h"
#import "YSFRefundDetail.h"
#import "YSFActivePage.h"
#import "YSFBotText.h"
#import "YSFSelectedGoods.h"
#import "YSFOrderOperation.h"
#import "YSFActionList.h"

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
            case YSFCommandBot:
            {
                NSString *type = [dict ysf_jsonString:@"type"];
                NSDictionary *tempateDict = [dict ysf_jsonDict:@"template"];
                NSString *verString =  [tempateDict ysf_jsonString:YSFApiKeyVersion];
                if (verString.length > 0 && ![verString isEqualToString:@"0.1"]) {
                    return object;
                }
                
                if ([type isEqualToString:@"01"]) {
                    YSFBotText *botText = [YSFBotText objectByDict:dict];
                    object = botText;
                }
                else if ([type isEqualToString:@"11"]) {
                    NSString *templeteId = [tempateDict ysf_jsonString:@"id"];
                    if ([templeteId isEqualToString:@"order_list"]) {
                        YSFOrderList *orderList = [YSFOrderList objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"order_status"]) {
                        YSFOrderStatus *orderList = [YSFOrderStatus objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"refund_detail"]) {
                        YSFRefundDetail *orderList = [YSFRefundDetail objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"order_detail"]) {
                        YSFOrderDetail *orderList = [YSFOrderDetail objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"order_logistic"]) {
                        YSFOrderLogistic *orderList = [YSFOrderLogistic objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"action_list"]) {
                        YSFActionList *orderList = [YSFActionList objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:@"active_page"]) {
                        YSFActivePage *activePage = [YSFActivePage objectByDict:tempateDict];
                        object = activePage;
                    }
                    else if ([templeteId isEqualToString:@"error_msg"]) {
                        YSFMachineResponse *response = [YSFMachineResponse new];
                        response.command = YSFCommandMachine;
                        response.answerLabel = [tempateDict ysf_jsonString:@"label"];
                        object = response;
                    }
                    else {
                        //assert(false);
                    }
                }
                else {
                    //assert(false);
                }

            }
                break;
            case YSFCommandBotSelection:
            {
                NSDictionary *tempateDict = [dict ysf_jsonDict:@"template"];
                NSString *templeteId = [tempateDict ysf_jsonString:@"id"];
                if ([templeteId isEqualToString:@"qiyu_template_text"]) {
                    object = [YSFOrderOperation objectByDict:dict];
                }
                else if ([templeteId isEqualToString:@"qiyu_template_goods"]) {
                    object = [YSFSelectedGoods objectByDict:dict];
                }
                else {
                    //assert(false);
                }
            }
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
                //assert(false);
                YSFLogErr(@"%zd not supported",command);

                break;
        }
    }
    
    return object;
}
@end

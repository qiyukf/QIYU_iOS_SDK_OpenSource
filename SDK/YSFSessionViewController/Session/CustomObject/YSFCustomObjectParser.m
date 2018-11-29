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
#import "YSFWelcome.h"
#import "YSFSessionClose.h"
#import "YSFNotification.h"
#import "YSFKFBypassNotification.h"
#import "YSFReportQuestion.h"
#import "QYCommodityInfo_private.h"
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
#import "YSFRichText.h"
#import "YSFBotForm.h"
#import "YSFStaticUnion.h"
#import "YSFSubmittedBotForm.h"
#import "YSFFlightList.h"
#import "YSFFlightDetail.h"
#import "YSFBotCustomObject.h"
#import "YSFMixReply.h"
#import "YSFMiniProgramPage.h"
#import "YSFCustomMessageAttachment.h"

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
                object = [QYCommodityInfo objectByDict:dict];
                break;
            case YSFCommandRichText:
                object = [YSFRichText objectByDict:dict];
                break;
            case YSFCommandBotReceive:
            {
                NSString *type = [dict ysf_jsonString:@"type"];
                NSDictionary *tempateDict = [dict ysf_jsonDict:@"template"];
                NSString *verString =  [tempateDict ysf_jsonString:YSFApiKeyVersion];
                CGFloat version = [verString floatValue];
                if (version > 1) {
                    return object;
                }
                
                if ([type isEqualToString:@"01"]) {
                    YSFBotText *botText = [YSFBotText objectByDict:dict];
                    object = botText;
                }
                else if ([type isEqualToString:@"11"]) {
                    NSString *templeteId = [tempateDict ysf_jsonString:@"id"];
                    if ([templeteId isEqualToString:YSFApiKeyOrderList]) {
                        YSFOrderList *orderList = [YSFOrderList objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyOrderStatus2]) {
                        YSFOrderStatus *orderList = [YSFOrderStatus objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyRefundDetail]) {
                        YSFRefundDetail *orderList = [YSFRefundDetail objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyOrderDetail]) {
                        YSFOrderDetail *orderList = [YSFOrderDetail objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyOrderLogistic]) {
                        YSFOrderLogistic *orderList = [YSFOrderLogistic objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyActionList]) {
                        YSFActionList *orderList = [YSFActionList objectByDict:tempateDict];
                        object = orderList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyMixReply]) {
                        YSFMixReply *mixReply = [YSFMixReply objectByDict:tempateDict];
                        object = mixReply;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyActivePage]) {
                        YSFActivePage *activePage = [YSFActivePage objectByDict:tempateDict];
                        object = activePage;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyStaticUnion]) {
                        YSFStaticUnion *staticUnion = [YSFStaticUnion objectByDict:tempateDict];
                        object = staticUnion;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyBotForm]) {
                        YSFBotForm *botForm = [YSFBotForm objectByDict:tempateDict];
                        object = botForm;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyCardLayout]) {
                        YSFFlightList *fightList = [YSFFlightList objectByDict:tempateDict];
                        object = fightList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyDetailView]) {
                        YSFFlightThumbnailAndDetail *fightDetail = [YSFFlightThumbnailAndDetail objectByDict:tempateDict];
                        YSFFlightList *fightList = [YSFFlightList objectByFlightThumbnail:fightDetail.thumbnail];
                        fightList.detail = fightDetail.detail;
                        object = fightList;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyErrorMsg]) {
                        YSFMachineResponse *response = [YSFMachineResponse new];
                        response.command = YSFCommandMachine;
                        response.answerLabel = [tempateDict ysf_jsonString:@"label"];
                        object = response;
                    }
                    else if ([templeteId isEqualToString:YSFApiKeyCustom]) {
                        YSFBotCustomObject *customObject = [YSFBotCustomObject new];
                        customObject.customObject = [tempateDict ysf_jsonArray:@"list"];
                        object = customObject;
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
            case YSFCommandBotSend:
            {
                NSDictionary *tempateDict = [dict ysf_jsonDict:@"template"];
                NSString *templeteId = [tempateDict ysf_jsonString:@"id"];
                if ([templeteId isEqualToString:@"qiyu_template_text"]) {
                    object = [YSFOrderOperation objectByDict:dict];
                }
                else if ([templeteId isEqualToString:@"qiyu_template_goods"]) {
                    object = [YSFSelectedCommodityInfo objectByDict:dict];
                }
                else if ([templeteId isEqualToString:@"qiyu_template_botForm"]) {
                    object = [YSFSubmittedBotForm objectByDict:dict];
                }
                else if ([templeteId isEqualToString:@"qiyu_template_mixReply"]) {
                    object = [YSFOrderOperation objectByDict:dict];
                }
                else {
                    //assert(false);
                }
            }
                break;
                
            //移动工作台
            case YSFCommandNewSession:
            {
                NSString *text = nil;
                NSInteger old_session_type = [dict ysf_jsonInteger:@"old_session_type"];
                if (old_session_type == 4) {
                    NSString *realname = [[[dict ysf_jsonString:@"oldStaffInfo"] ysf_toDict] ysf_jsonString:@"realname"];
                    text = [NSString stringWithFormat:@"已收到来自%@转接的会话", realname];
                } else {
                    text = @"用户进入";
                }
                YSFNotification *notification = [YSFNotification new];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandNewSession;
                notification.message = text;
                object = notification;
            }
                break;
            case YSFCommandWelcome:
            {
                NSString *welcome = [dict ysf_jsonString:YSFApiKeyWelcomeRichText];
                if (!welcome) {
                    welcome = [dict ysf_jsonString:YSFApiKeyWelcome];
                }
                if (!welcome) {
                    welcome = @"";
                }
                YSFRichText *richText = [YSFRichText objectByParams:YSFCommandRichText content:welcome];
                object = richText;
            }
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
            case YSFCommandMiniProgramPage:
                object = [YSFMiniProgramPage objectByDict:dict];
                break;
            case YSFCommandCustomMessage:
                object = [YSFCustomMessageAttachment objectByDict:dict];
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

//
//  YSFApiDefines.h
//  YSFSDK
//
//  Created by amao on 9/8/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef YSFSDK_YSFApiDefines_h
#define YSFSDK_YSFApiDefines_h

#define     YSFApiKeyCmd                @"cmd"
#define     YSFApiKeyLocalCmd           @"localcmd"
#define     YSFApiKeyAppKey             @"appkey"
#define     YSFApiKeyDeviceId           @"deviceid"
#define     YSFApiKeyInfo               @"info"
#define     YSFApiKeyCode               @"code"
#define     YSFApiKeyURI                @"uri"
#define     YSFApiKeyExchange           @"exchange"
#define     YSFApiKeyBefore             @"before"
#define     YSFApiKeyFromTitle          @"fromTitle"
#define     YSFApiKeyFromPage           @"fromPage"
#define     YSFApiKeyFromCustom         @"fromCustom"
#define     YSFApiKeyFromBundleId       @"bundleid"
#define     YSFApiKeyUserId             @"userid"
#define     YSFApiKeyForeignid          @"foreignid"
#define     YSFApiKeyUserInfo           @"userinfo"
#define     YSFApiKeySessionId          @"sessionid"
#define     YSFApiKeyShop               @"shop"
#define     YSFApiKeyLogo               @"logo"
#define     YSFApiKeyName               @"name"
#define     YSFApiKeyBId                @"bid"
#define     YSFApiKeyEntries            @"entries"
#define     YSFApiKeyDisable            @"disable"
#define     YSFApiKeyOldSessionId       @"old_sessionid"
#define     YSFApiKeyOldSessionType     @"old_sessiontype"
#define     YSFApiKeyCategory           @"category"
#define     YSFApiKeyFromType           @"fromType"
#define     YSFApiKeyFromSubType        @"fromSubType"
#define     YSFApiKeyFromIp             @"fromIp"
#define     YSFApiKeyForeignId          @"foreignid"
#define     YSFApiKeyStaffId            @"staffid"
#define     YSFApiKeyStaffName          @"staffname"
#define     YSFApiKeyGroupName          @"groupname"
#define     YSFApiKeyIconUrl            @"iconurl"
#define     YSFApiKeyMessage            @"message"
#define     YSFApiKeyEvaluation         @"evaluation"
#define     YSFApiKeyEvaluationData     @"evaluation_data"
#define     YSFApiKeyStaffType          @"stafftype"
#define     YSFApiKeyVersion            @"version"
#define     YSFApiKeyStaffId            @"staffid"
#define     YSFApiKeyRealStaffId        @"realStaffid"
#define     YSFApiKeyGroupId            @"groupid"
#define     YSFApiKeyQuestion           @"question"
#define     YSFApiKeyQuestionId         @"questionid"
#define     YSFApiKeyLabel              @"label"
#define     YSFApiKeyId                 @"id"
#define     YSFApiKeyEntryId            @"entryid"
#define     YSFApiKeyCommonQuestionTemplateId  @"qtype"
#define     YSFApiKeyRobotShuntSwitch   @"robotShuntSwitch"
#define     YSFApiKeyAnswerType         @"answer_type"
#define     YSFApiKeyAnswerLabel        @"answer_label"
#define     YSFApiKeyAnswerCount        @"answer_cnt"
#define     YSFApiKeyAnswerList         @"answer_list"
#define     YSFApiKeyAnswer             @"answer"
#define     YSFApiKeyOperatorHint       @"operator_hint"
#define     YSFApiKeyOperatorHintDesc   @"operator_hint_desc"
#define     YSFApiKeyOperatorEnable     @"operator_enable"
#define     YSFApiKeyEvaluation         @"evaluation"
#define     YSFApiKeyRemarks            @"remarks"
#define     YSFApiKeyList               @"list"
#define     YSFApiKeyMessage            @"message"
#define     YSFApiKeyOriginalQuestion   @"original_question"
#define     YSFApiKeyMatchedQuestion    @"matched_question"
#define     YSFApiKeyAnswer             @"answer"
#define     YSFApiKeyTipContent         @"tip_content"
#define     YSFApiKeyTipResult          @"tip_result"
#define     YSFApiKeyStatus             @"status"
#define     YSFApiKeyCount              @"count"
#define     YSFApiLoginCookie           @"login_cookie"
#define     YSFApiKeyWelcome            @"welcome"
#define     YSFApiKeyCloseType          @"closeType"
#define     YSFApiKeyEvaluate           @"evaluate"
#define     YSFApiKeyPlatform           @"platform"
#define     YSFApiKeyFrom               @"from"
#define     YSFApiKeyTo                 @"to"
#define     YSFApiKeyType               @"type"
#define     YSFApiKeyBody               @"body"
#define     YSFApiKeyValid              @"valid"
#define     YSFApiKeyTitle              @"title"
#define     YSFApiKeyDesc               @"desc"
#define     YSFApiKeyPicture            @"picture"
#define     YSFApiKeyUrl                @"url"
#define     YSFApiKeyNote               @"note"
#define     YSFApiKeyShow               @"show"
#define     YSFApiKeyMsgId              @"msgId"
#define     YSFApiKeyText               @"text"
#define     YSFApiKeyMessageId          @"msgId"
#define     YSFApiKeyMessageSessionId   @"msgSessionId"
#define     YSFApiKeyFromImId           @"fromImId"
#define     YSFApiKeyContent            @"content"



#define     YSFApiValueIOS              @"iOS"

typedef enum : NSUInteger {
    //访客端
    YSFCommandRequestServiceRequest     =   1,      //请求客服
    YSFCommandRequestServiceResponse    =   2,      //请求客服回包
    YSFCommandAddUserInfoRequest        =   4,      //添加用户信息
    YSFCommandSetLeaveStatusRequest     =   5,      //用户离开当前会话
    YSFCommandCloseServiceRequest       =   6,      //关闭客服请求
    YSFCommandHeatbeatPacketRequest     =   8,      //客服心跳协议
    YSFCommandReadSessionRequest        =   9,      //会话已读标记
    YSFCommandWaitingStatusResponse     =   15,     //等待状态回包
    YSFCommandWaitingStatusRequest      =   16,     //查询等待状态
    YSFCommandEvaluationRequest         =   51,     //满意度评价
    YSFCommandSetUserInfoRequest        =   52,     //轻量CRM
    YSFCommandMachine                   =   60,     //机器人问答
    YSFCommandKFBypassNotification      =   90,     //客服分流
    YSFCommandSetCommodityInfoRequest   =   121,    //商品信息
    YSFCommandPushMessageRequest        =   133,    //获取推送消息
    YSFCommandPushMessageStatusChangeRequest =   135,    //推送消息状态变更


    //客服端
    YSFCommandCloseServiceResponse      =   7,      //关闭客服
    YSFCommandUserSwitchAccount         =   11,     //用户切换账号
    YSFCommandSetOnlineState            =   12,     //设置客服在线状态
    YSFCommandWeChatMessage             =   20,     //微信消息
    YSFCommandNewSession                =   3,      //有新的会话
    YSFCommandWelcome                   =   40,     //欢迎语
    YSFCommandKefuLogout                =   10,     //客服登出
    YSFCommandUserOffline               =   18,     //客户离线了
    YSFCommandReportQuestion            =   63,     //选择问题
    YSFCommandSessionClose              =   84,     //自定义消息；会话关闭
    YSFCommandSendLogin                 =   85,     //通知其他端的自己被踢出
    YSFCommandQueueChanged              =   82,     //排队人数变化
    YSFCommandSessionWillClose          =   70,     //用户没有回复，稍后系统将关闭
    YSFCommandSessionClosedBySysterm    =   71,     //系统自动关闭会话
    YSFCommandAudioToText               =   136,    //推送语音转文字结果
    YSFCommandOfflineTimeout            =   32,    //离线时间超时
    

    //本地自定义消息
    YSFCommandEvaluationTip             =   10001,  //评价提示
    YSFCommandNotification              =   10002,  //只有message字段
    YSFCommandNewMessage                =   10003,  //新消息提示
    YSFCommandInviteEvaluation          =   10004,  //邀请评价


} YSFCommand;


typedef enum : NSUInteger {
    YSFCodeServerTimeout        = -2,       //服务器超时
    YSFCodeSuccess              = 200,      //成功
    YSFCodeServiceNotExist      = 201,      //客服不在线
    YSFCodeServiceWaiting       = 203,      //正在排队
    YSFCodeBundleIdInvalid      = 204,      //bundleid无效
    YSFCodeServiceWaitingToStartService = 301,      //排队返回值，从排队状态进入服务状态
    YSFCodeServiceWaitingToInvalid      = 302,      //排队返回值，错误或者排队失效等

} YSFCode;



#endif

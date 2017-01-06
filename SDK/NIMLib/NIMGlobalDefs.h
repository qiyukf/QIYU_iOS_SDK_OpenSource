//
//  NIMGlobalDefs.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_NIMGlobalDefs_h
#define NIMLib_NIMGlobalDefs_h



/**
 *  消息内容类型枚举
 */
typedef NS_ENUM(NSInteger, YSF_NIMMessageType){
    /**
     *  文本类型消息
     */
    YSF_NIMMessageTypeText          = 0,
    /**
     *  图片类型消息
     */
    YSF_NIMMessageTypeImage         = 1,
    /**
     *  声音类型消息
     */
    YSF_NIMMessageTypeAudio         = 2,
    /**
     *  视频类型消息
     */
    YSF_NIMMessageTypeVideo         = 3,
    /**
     *  位置类型消息
     */
    YSF_NIMMessageTypeLocation      = 4,
    /**
     *  通知消息
     */
    YSF_NIMMessageTypeNotification  = 5,
    /**
     *  文件消息
     */
    YSF_NIMMessageTypeFile          = 6,
    /**
     *  提示消息
     */
    YSF_NIMMessageTypeTip           = 10,
    
    /**
     *  自定义消息
     */
    YSF_NIMMessageTypeCustom        = 100
};


/**
 *  网络通话类型
 */
typedef NS_ENUM(NSInteger, YSF_NIMNetCallType){
    /**
     *  音频通话
     */
    YSF_NIMNetCallTypeAudio = 1,
    /**
     *  视频通话
     */
    YSF_NIMNetCallTypeVideo = 2,
};



/**
 *  NIM本地Error Domain
 */
extern NSString *const YSF_NIMLocalErrorDomain;

/**
 *  NIM服务器Error Domain
 */
extern NSString *const YSF_NIMRemoteErrorDomain;



/**
 *  本地错误码
 */
typedef NS_ENUM(NSInteger, YSF_NIMLocalErrorCode) {
    /**
     *  错误的参数
     */
    YSF_NIMLocalErrorCodeInvalidParam                 = 1,
    /**
     *  多媒体文件异常
     */
    YSF_NIMLocalErrorCodeInvalidMedia                 = 2,
    /**
     *  图片异常
     */
    YSF_NIMLocalErrorCodeInvalidPicture               = 3,
    /**
     *  url异常
     */
    YSF_NIMLocalErrorCodeInvalidUrl                   = 4,
    /**
     *  读取/写入文件失败
     */
    YSF_NIMLocalErrorCodeIOError                      = 5,
    /**
     *  无效的token
     */
    YSF_NIMLocalErrorCodeInvalidToken                 = 6,
    /**
     *  Http请求失败
     */
    YSF_NIMLocalErrorCodeHttpReqeustFailed            = 7,
    /**
     *  无录音权限
     */
    YSF_NIMLocalErrorCodeAudioRecordErrorNoPermission = 8,
    /**
     *  录音初始化失败
     */
    YSF_NIMLocalErrorCodeAudioRecordErrorInitFailed   = 9,
    /**
     *  录音失败
     */
    YSF_NIMLocalErrorCodeAudioRecordErrorRecordFailed   = 10,
    /**
     *  播放初始化失败
     */
    YSF_NIMLocalErrorCodeAudioPlayErrorInitFailed     = 11,
    /**
     *  有正在进行的网络通话
     */
    YSF_NIMLocalErrorCodeNetCallBusy                  = 12,
    /**
     *  这一通网络通话已经被其他端处理过了
     */
    YSF_NIMLocalErrorCodeNetCallOtherHandled          = 13,
    /**
     *  SQL语句执行失败
     */
    YSF_NIMLocalErrorCodeSQLFailed                    = 14,
    /**
     *  音频设备初始化失败
     */
    YSF_NIMLocalErrorCodeAudioDeviceInitFailed        = 15,
    
    /**
     *  用户信息缺失 (未登录 或 未提供用户资料)
     */
    YSF_NIMLocalErrorCodeUserInfoNeeded               = 16,
};




/**
 *  服务器错误码
 *  @discussion 更多错误详见 http://dev.netease.im/docs/index.php?index=6&title=%E5%85%A8%E5%B1%80%E8%BF%94%E5%9B%9E%E7%A0%81%E8%AF%B4%E6%98%8E
 */
typedef NS_ENUM(NSInteger, YSF_NIMRemoteErrorCode) {
    /**
     *  客户端版本错误
     */
    YSF_NIMRemoteErrorCodeInvalidVersion      = 201,
    /**
     *  密码错误
     */
    YSF_NIMRemoteErrorCodeInvalidPass         = 302,
    /**
     *  CheckSum校验失败
     */
    YSF_NIMRemoteErrorCodeInvalidCRC          = 402,
    /**
     *  非法操作或没有权限
     */
    YSF_NIMRemoteErrorCodeForbidden           = 403,
    /**
     *  请求的目标（用户或对象）不存在
     */
    YSF_NIMRemoteErrorCodeNotExist            = 404,
    /**
     *  对象只读
     */
    YSF_NIMRemoteErrorCodeReadOnly            = 406,
    /**
     *  请求过程超时
     */
    YSF_NIMRemoteErrorCodeTimeoutError        = 408,
    /**
     *  参数错误
     */
    YSF_NIMRemoteErrorCodeParameterError      = 414,
    /**
     *  网络连接出现错误
     */
    YSF_NIMRemoteErrorCodeConnectionError     = 415,
    /**
     *  操作太过频繁
     */
    YSF_NIMRemoteErrorCodeFrequently          = 416,
    /**
     *  对象已经存在
     */
    YSF_NIMRemoteErrorCodeExist               = 417,
    /**
     *  未知错误，或者不方便告诉你
     */
    YSF_NIMRemoteErrorCodeUnknownError        = 500,
    /**
     *  服务器数据错误
     */
    YSF_NIMRemoteErrorCodeServerDataError     = 501,
    /**
     *  不足
     */
    YSF_NIMRemoteErrorCodeNotEnough           = 507,
    /**
     *  超过期限
     */
    YSF_NIMRemoteErrorCodeDomainExpireOld     = 508,
    /**
     *  无效协议
     */
    YSF_NIMRemoteErrorCodeInvalidProtocol      = 509,
    /**
     *  用户不存在
     */
    YSF_NIMRemoteErrorCodeUserNotExist        = 510,
    /**
     *  服务不可用
     */
    YSF_NIMRemoteErrorCodeServiceUnavailable  = 514,
    /**
     *  没有操作群的权限
     */
    YSF_NIMRemoteErrorCodeTeamAccessError     = 802,
    /**
     *  群组不存在
     */
    YSF_NIMRemoteErrorCodeTeamNotExists       = 803,
    /**
     *  用户不在兴趣组内
     */
    YSF_NIMRemoteErrorCodeNotInTeam           = 804,
    /**
     *  群类型错误
     */
    YSF_NIMRemoteErrorCodeTeamInvaildType     = 805,
    /**
     *  超出群成员个数限制
     */
    YSF_NIMRemoteErrorCodeTeamMemberLimit     = 806,
    /**
     *  已经在群里
     */
    YSF_NIMRemoteErrorCodeTeamAlreadyIn       = 809,
    /**
     *   不是群成员
     */
    YSF_NIMRemoteErrorCodeTeamNotMember       = 810,
    /**
     *  在群黑名单中
     */
    YSF_NIMRemoteErrorCodeTeamBlackList       = 812,
    /**
     *  解包错误
     */
    YSF_NIMRemoteErrorCodeEUnpacket           = 998,
    /**
     *  打包错误
     */
    YSF_NIMRemoteErrorCodeEPacket             = 999,
    
    /**
     *  被叫离线(无可送达的被叫方)
     */
    YSF_NIMRemoteErrorCodeCalleeOffline       = 11001,
};




#endif

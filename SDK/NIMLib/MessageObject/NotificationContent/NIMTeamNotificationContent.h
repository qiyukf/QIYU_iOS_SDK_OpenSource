//
//  YSF_NIMTeamNotificationContent.h
//  NIMLib
//
//  Created by Netease
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNotificationContent.h"


/**
 *  群操作类型
 */
typedef NS_ENUM(NSInteger, YSF_NIMTeamOperationType){
    /**
     *  邀请成员
     */
    YSF_NIMTeamOperationTypeInvite          = 0,
    /**
     *  移除成员
     */
    YSF_NIMTeamOperationTypeKick            = 1,
    /**
     *  离开群
     */
    YSF_NIMTeamOperationTypeLeave           = 2,
    /**
     *  更新群信息
     */
    YSF_NIMTeamOperationTypeUpdate          = 3,
    /**
     *  解散群
     */
    YSF_NIMTeamOperationTypeDismiss         = 4,
    /**
     *  高级群申请加入成功
     */
    YSF_NIMTeamOperationTypeApplyPass       = 5,
    /**
     *  高级群群主转移群主身份
     */
    YSF_NIMTeamOperationTypeTransferOwner   = 6,
    /**
     *  添加管理员
     */
    YSF_NIMTeamOperationTypeAddManager      = 7,
    /**
     *  移除管理员
     */
    YSF_NIMTeamOperationTypeRemoveManager   = 8,
    /**
     *  高级群接受邀请进群
     */
    YSF_NIMTeamOperationTypeAcceptInvitation= 9,
    
};


/**
 *  群信息修改字段
 */
typedef NS_ENUM(NSInteger, YSF_NIMTeamUpdateTag){
    /**
     *  群名
     */
    YSF_NIMTeamUpdateTagName            = 3,
    /**
     *  群简介
     */
    YSF_NIMTeamUpdateTagIntro           = 14,
    /**
     *  群公告
     */
    YSF_NIMTeamUpdateTagAnouncement     = 15,
    /**
     *  群验证方式
     */
    YSF_NIMTeamUpdateTagJoinMode        = 16,
    /**
     *  客户端自定义拓展字段
     */
    YSF_NIMTeamUpdateTagClientCustom    = 18,
    /**
     *  服务器自定义拓展字段
     *  @discussion SDK 无法直接修改这个字段
     */
    YSF_NIMTeamUpdateTagServerCustom    = 19,
    
};



/**
 *  群通知内容
 */
@interface YSF_NIMTeamNotificationContent : YSF_NIMNotificationContent
/**
 *  操作发起者ID
 */
@property (nonatomic,copy,readonly)     NSString    *sourceID;

/**
 *  操作类型
 */
@property (nonatomic,assign,readonly)   YSF_NIMTeamOperationType  operationType;

/**
 *  被操作者ID列表
 */
@property (nonatomic,strong,readonly)   NSArray *targetIDs;

/**
 *  额外信息
 *  @discussion 目前只有群信息更新才有attachment,attachment为YSF_NIMUpdateTeamInfoAttachment
 */
@property (nonatomic,strong,readonly)   id attachment;
@end


/**
 *  更新群信息的额外信息
 */
@interface YSF_NIMUpdateTeamInfoAttachment : NSObject

/**
 *  群内修改的信息键值对
 */
@property (nonatomic,strong,readonly)   NSDictionary    *values;
@end


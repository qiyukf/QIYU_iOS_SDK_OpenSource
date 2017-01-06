//
//  YSF_NIMTeamMember.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  群成员类型
 */
typedef NS_ENUM(NSInteger, YSF_NIMTeamMemberType){
    /**
     *  普通群员
     */
    YSF_NIMTeamMemberTypeNormal = 0,
    /**
     *  群拥有者
     */
    YSF_NIMTeamMemberTypeOwner = 1,
    /**
     *  群管理员
     */
    YSF_NIMTeamMemberTypeManager = 2,
    /**
     *  申请加入用户
     */
    YSF_NIMTeamMemberTypeApply   = 3,
};


/**
 *  群成员信息
 */
@interface YSF_NIMTeamMember : NSObject
/**
 *  群ID
 */
@property (nonatomic,copy,readonly)         NSString *teamId;

/**
 *  群成员ID
 */
@property (nonatomic,copy,readonly)         NSString *userId;

/**
 *  邀请者
 */
@property (nonatomic,copy,readonly)         NSString *invitor;

/**
 *  群成员类型
 */
@property (nonatomic,assign)                YSF_NIMTeamMemberType  type;


/**
 *  群昵称
 */
@property (nonatomic,copy)                  NSString *nickname;

@end
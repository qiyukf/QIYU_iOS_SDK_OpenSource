//
//  YSF_NIMSession.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  会话类型
 */
typedef NS_ENUM(NSInteger, YSF_NIMSessionType){
    /**
     *  点对点
     */
    YSF_NIMSessionTypeP2P  = 0,
    /**
     *  群组
     */
    YSF_NIMSessionTypeTeam = 1,
    
    /**
     *  云商服
     */
    YSF_NIMSessionTypeYSF  = 3,
};




/**
 *  会话对象
 */
@interface YSF_NIMSession : NSObject<NSCopying>

/**
 *  会话ID,如果当前session为team,则sessionId为teamId,如果是P2P则为对方帐号
 */
@property (nonatomic,copy,readonly)         NSString *sessionId;

/**
 *  会话类型,当前仅支持P2P和Team
 */
@property (nonatomic,assign,readonly)       YSF_NIMSessionType sessionType;


/**
 *  通过id和type构造会话对象
 *
 *  @param sessionId   会话ID
 *  @param sessionType 会话类型
 *
 *  @return 会话对象实例
 */
+ (instancetype)session:(NSString *)sessionId
                   type:(YSF_NIMSessionType)sessionType;

@end

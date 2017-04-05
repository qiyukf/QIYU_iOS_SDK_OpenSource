//
//  QYSessionInfo.m
//  YSFSDK
//
//  Created by towik on 16/12/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "QYMessageInfo.h"

@interface QYMessageInfo()

/**
 *  会话ID，可以是商铺ID等
 */
@property (nonatomic, copy) NSString *shopId;

/**
 *  会话头像URL
 */
@property (nonatomic, copy) NSString *avatarImageUrlString;

/**
 *  发送者
 */
@property (nonatomic, copy) NSString *sender;

@end



@implementation QYMessageInfo

@end

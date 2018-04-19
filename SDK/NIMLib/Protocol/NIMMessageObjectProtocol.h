//
//  NIMMessageObjectProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"
@class YSF_NIMMessage;


/**
 *  消息体协议
 */
@protocol YSF_NIMMessageObject <NSObject>

- (NSString *)thumbText;

/**
 *  消息体所在的消息对象
 */
@property (nonatomic, weak) YSF_NIMMessage *message;

/**
 *  消息内容类型
 *
 *  @return 消息内容类型
 */
- (YSF_NIMMessageType)type;

//解码
- (void)decodeWithContent:(NSString*)content;

@end

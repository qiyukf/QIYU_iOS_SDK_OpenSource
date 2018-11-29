//
//  QYCustomMessage_Private.h
//  YSFSDK
//
//  Created by liaosipei on 2018/11/23.
//  Copyright © 2018 Netease. All rights reserved.
//

@interface QYCustomMessage()

/**
 *  消息唯一ID
 */
@property (nonatomic, copy, readwrite) NSString *messageId;

/**
 *  消息来源
 */
@property (nonatomic, assign, readwrite) QYCustomMessageSourceType sourceType;

@end

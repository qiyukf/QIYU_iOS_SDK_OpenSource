//
//  YSFDataTrackRequest.h
//  YSFSDK
//
//  Created by liaosipei on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFIMCustomSystemMessageApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFDataTrackRequest : NSObject <YSFIMCustomSystemMessageApiProtocol>

/**
 *  事件类型
 */
@property (nonatomic, copy) NSString *type;

/**
 *  会话ID
 */
@property (nonatomic, assign) long long sessionId;

/**
 *  该事件要上报的业务数据字段
 */
@property (nonatomic, copy) NSDictionary *jsonDict;

@end

NS_ASSUME_NONNULL_END

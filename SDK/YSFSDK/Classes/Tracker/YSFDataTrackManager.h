//
//  YSFDataTrackManager.h
//  YSFSDK
//
//  Created by liaosipei on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YSFDataTrackEventType) {
    YSFDataTrackEventTypeNone = 0,           //none
    YSFDataTrackEventTypeBotDirectButton,    //机器人一触即达按钮点击事件
};

NS_ASSUME_NONNULL_BEGIN

@interface YSFDataTrackManager : NSObject

/**
 *  获取埋点单例
 */
+ (instancetype)sharedManager;

/**
 *  向服务端上报埋点数据
 *  @param type 事件类型
 *  @param data 该事件上报的业务数据
 *  @param shopId 商铺ID
 *  @param sessionId 会话ID
 */
- (void)trackEventType:(YSFDataTrackEventType)type
                  data:(NSDictionary *)data
                shopId:(NSString *)shopId
             sessionId:(long long)sessionId;

@end

NS_ASSUME_NONNULL_END

//
//  YSFSessionManager.h
//  YSFSDK
//
//  Created by amao on 8/31/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFServiceSession.h"
#import "YSFRequestServiceRequest.h"
#import "YSFCloseServiceNotification.h"

typedef enum : NSUInteger {
    YSFSessionStateTypeError,                       //离线
    YSFSessionStateTypeOnline,                      //正在服务
    YSFSessionStateTypeNotExist,                    //客服不在线
    YSFSessionStateNotExistAndLeaveMessageClosed,   //客服不在线
    YSFSessionStateTypeWaiting,                     //正在排队
} YSFSessionStateType;

@class QYSource;
@class QYStaffInfo;
@protocol YSFSessionProtocol <NSObject>

- (void)didBeginSendReqeustWithShopId:(NSString *)shopId;
- (void)didSendSessionRequest:(NSError *)error shopId:(NSString *)shopId;
- (void)didReceiveSessionError:(NSError *)error
                       session:(YSFServiceSession *)session
                        bypass:(BOOL)bypass
                        shopId:(NSString *)shopId;
- (void)didClose:(BOOL)evaluate session:(YSFServiceSession *)session shopId:(NSString *)shopId;

@end


@interface YSFSessionManager : NSObject

@property (nonatomic, weak) id<YSFSessionProtocol> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *sessions; //当前会话列表
@property (nonatomic, strong) QYStaffInfo *staffInfo;

- (void)readData;

- (BOOL)shouldRequestService:(BOOL)isInit shopId:(NSString *)shopId;
- (void)requestServiceWithSource:(YSFRequestServiceRequest *)request shopId:(NSString *)shopId;

- (YSFSessionStateType)getSessionStateType:(NSString *)shopId;
- (YSFServiceSession *)getOnlineSession:(NSString *)shopId;
- (YSFServiceSession *)getOnlineOrWaitingSession:(NSString *)shopId;

- (void)addStaffIconURL:(NSString *)iconURL forStaffId:(NSString *)staffId;
- (NSString *)getIconURLFromStaffId:(NSString *)staffId;
- (void)updateStaffInfoForOnlineSession:(NSString *)shopId;
- (NSString *)getOnlineStaffId:(NSString *)shopId;

- (NSDictionary *)getShopInfo;
- (void)removeShopInfo:(NSString *)shopId;

- (void)setLastSessionId:(long long)sessionId forShopId:(NSString *)shopId;
- (long long)getLastSessionIdForShopId:(NSString *)shopId;

- (NSDictionary *)getRecentEvaluationMemoryDataByShopId:(NSString *)shopId;
- (NSDictionary *)getHistoryEvaluationMemoryDataByShopId:(NSString *)shopId sessionId:(long long)sessionId;
- (NSDictionary *)getRecentEvaluationPersistDataByShopId:(NSString *)shopId;
- (NSDictionary *)getHistoryEvaluationPersistDataByShopId:(NSString *)shopId sessionId:(long long)sessionId;
- (void)setRecentEvaluationData:(NSDictionary *)data shopId:(NSString *)shopId;
- (void)setHistoryEvaluationData:(NSDictionary *)data shopId:(NSString *)shopId sessionId:(long long)sessionId;

- (void)reportPushMessageReadedStatus;
- (long long)getLastUnreadPushMessageSessionId;

- (void)clear;
- (void)clearByShopId:(NSString *)shopId;

@end

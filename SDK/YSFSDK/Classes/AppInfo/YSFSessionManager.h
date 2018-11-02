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
                        shopId:(NSString *)shopId;
- (void)didClose:(BOOL)evaluate session:(YSFServiceSession *)session shopId:(NSString *)shopId;

@end


@interface YSFSessionManager : NSObject

@property (nonatomic, weak) id<YSFSessionProtocol> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *sessions; //当前会话列表
@property (nonatomic, strong) QYStaffInfo *staffInfo;

- (void)readData;

- (NSDictionary *)getEvaluationInfoByShopId:(NSString *)shopId;
- (void)setEvaluationInfo:(NSDictionary *)evaluation shopId:(NSString *)shopId;

- (NSDictionary *)getShopInfo;
- (void)removeShopInfo:(NSString *)shopId;

- (void)reportPushMessageReadedStatus;
- (long long)getLastUnreadPushMessageSessionId;

- (BOOL)shouldRequestService:(BOOL)isInit shopId:(NSString *)shopId;
- (void)requestServiceWithSource:(YSFRequestServiceRequest *)request shopId:(NSString *)shopId;

- (YSFSessionStateType)getSessionStateType:(NSString *)shopId;
- (YSFServiceSession *)getOnlineSession:(NSString *)shopId;
- (YSFServiceSession *)getOnlineOrWaitingSession:(NSString *)shopId;

- (void)addStaffIconURL:(NSString *)iconURL forStaffId:(NSString *)staffId;
- (NSString *)getIconURLFromStaffId:(NSString *)staffId;
- (void)updateStaffInfoForOnlineSession:(NSString *)shopId;

- (void)clear;
- (void)clearByShopId:(NSString *)shopId;

@end

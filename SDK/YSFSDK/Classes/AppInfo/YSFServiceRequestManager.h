//
//  YSFServiceRequestManager.h
//  YSFSDK
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@protocol YSFServiceRequestDelegate <NSObject>
- (void)onServiceRequestTimeout:(NSString *)serviceId;
@end

@interface YSFServiceRequestManager : NSObject
@property (nonatomic,weak)  id<YSFServiceRequestDelegate>   delegate;

- (BOOL)isInRequest:(NSString *)shopId;

- (void)updateRequestState:(NSString *)shopId inRequest:(BOOL)inRequest;

- (void)startWaitResponseTimer:(NSString *)shopId;

- (void)stopWaitResponseTimer:(NSString *)shopId;
@end

//
//  YSFServiceRequestManager.m
//  YSFSDK
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFServiceRequestManager.h"
#import "YSFTimer.h"


@interface YSFServiceRequest : NSObject
@property (nonatomic,assign)    BOOL                inRequest;
@property (nonatomic,strong)    YSFTimer   *timer;

@end

@implementation YSFServiceRequest
- (instancetype)init
{
    if (self = [super init])
    {
        _timer = [[YSFTimer alloc] init];
    }
    return self;
}

@end

@interface YSFServiceRequestManager ()
@property (nonatomic,strong)    NSMutableDictionary *requests;
@end


@implementation YSFServiceRequestManager

- (instancetype)init
{
    if (self = [super init])
    {
        _requests = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isInRequest:(NSString *)shopId
{
    return [[self requestByServiceId:shopId] inRequest];
}

- (void)updateRequestState:(NSString *)shopId inRequest:(BOOL)inRequest
{
    [[self requestByServiceId:shopId] setInRequest:inRequest];
}

- (void)startWaitResponseTimer:(NSString *)shopId
{
    __weak typeof(self) weakself = self;
    [[[self requestByServiceId:shopId] timer] start:dispatch_get_main_queue() interval:15 repeats:NO block:^{
        [weakself onTimerFired:[[weakself requestByServiceId:shopId] timer]];
    }];
}

- (void)stopWaitResponseTimer:(NSString *)shopId
{
    [[[self requestByServiceId:shopId] timer] stop];
}

#pragma mark - misc
- (YSFServiceRequest *)requestByServiceId:(NSString *)shopId
{
    YSFServiceRequest *request = nil;
    if (shopId)
    {
        request = [_requests objectForKey:shopId];
        if (request == nil)
        {
            request = [[YSFServiceRequest alloc] init];
            [_requests setValue:request
                          forKey:shopId];
        }
    }
    return request;
}

#pragma mark - YSFKitTimerHolder
- (void)onTimerFired:(YSFTimer *)holder
{
    for (NSString *shopId in _requests.allKeys)
    {
        if ([[self requestByServiceId:shopId] timer] == holder)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(onServiceRequestTimeout:)])
            {
                [_delegate onServiceRequestTimeout:shopId];
            }
            break;
        }
    }
}

@end

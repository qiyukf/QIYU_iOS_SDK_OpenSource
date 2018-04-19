//
//  NIMDataTracker.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMDataTracker.h"
#import "NIMDeviceInfoProvider.h"
#import "NIMCarrierInfoProvider.h"
#import "NIMHostAppInfoProvider.h"
#import "NIMWifiInfoProvider.h"
#import "NIMDataTrackerConfig.h"
#import "NIMDataTrackerCategory.h"


#define NIM_DATA_TRACKER_URL    @"https://wfd.netease.im/statistic"



@implementation YSF_NIMDataTrackerOption
- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    long long time = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *appid = [[NSBundle mainBundle] bundleIdentifier];
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [headers ysfdt_setObject:_name forKey:@"nt-source"];
    [headers ysfdt_setObject:_appKey forKey:@"nt-appkey"];
    [headers ysfdt_setObject:_version forKey:@"nt-version"];
    [headers ysfdt_setObject:@"1" forKey:@"nt-system"];
    [headers ysfdt_setObject:idfv forKey:@"nt-deviceid"];
    [headers ysfdt_setObject:[NSString stringWithFormat:@"%lld",time] forKey:@"nt-time"];
    [headers ysfdt_setObject:appid
                      forKey:@"nt-appid"];
    
    return headers;
}
@end

@interface YSF_NIMDataTracker ()
@property (nonatomic,strong)    YSF_NIMDataTrackerOption    *option;
@property (nonatomic,strong)    NSOperationQueue        *trackQueue;
@property (nonatomic,assign)    BOOL                    inProgress;
@property (nonatomic,strong)    YSF_NIMDataTrackerConfig    *config;
@property (nonatomic,strong)    NSURLSession            *session;
@property (nonatomic,strong)    NSDate                  *lastRefreshConfigDate;
@end

@implementation YSF_NIMDataTracker
+ (instancetype)shared
{
    static YSF_NIMDataTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSF_NIMDataTracker alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        _trackQueue = [[NSOperationQueue alloc] init];
        [_trackQueue setMaxConcurrentOperationCount:1];
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:nil
                                            delegateQueue:_trackQueue];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (YSF_NIMDataTrackerConfig *)config
{
    if (_config == nil)
    {
        _config = [[YSF_NIMDataTrackerConfig alloc] init];
    }
    return _config;
}

#pragma mark - public api
- (void)start:(YSF_NIMDataTrackerOption *)option
{
    NSAssert([option.name length] > 0, @"name should not be empty");
    [_trackQueue addOperationWithBlock:^{
        if (option)
        {
            self.option = option;
            [self refreshConfig];
        }
    }];
}

- (void)trackEvent
{
    [self dispatchTrackEvent:nil];
}

- (void)trackEvent:(NSDictionary<NSString *,NSDictionary *> *)event
{
    [self dispatchTrackEvent:event];
}

#pragma mark - event handle
- (void)onEnterBackground:(NSNotification *)notification
{
    [self dispatchTrackEvent:nil];

    [_trackQueue addOperationWithBlock:^{
        [self refreshConfig];
    }];
}

- (void)onEnterForeground:(NSNotification *)notification
{
    [self dispatchTrackEvent:nil];
}

- (void)dispatchTrackEvent:(NSDictionary *)customEvent
{
    [_trackQueue addOperationWithBlock:^{
        if (self.option)
        {
            [self track:customEvent];
        }
    }];
}

#pragma mark - track
- (void)track:(NSDictionary *)customEvent
{
    if (self.inProgress)
    {
        YSFLogApp(@"ndtk refresh data cancelled because of in progress");
        return;
    }
    YSFLogApp(@"ndtk refresh data");
    self.inProgress = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSData *postData = nil;
    NSArray *categories = nil;
    if ([self.config trackable])
    {
        categories = [self.config  trackableCategories];
        for (NSNumber *item in categories)
        {
            NSInteger category = [item integerValue];
            switch (category) {
                case YSF_NIMDataTrackerConfigCategoryDevice:
                {
                    NSDictionary *jsonDict = [[YSF_NIMDeviceInfoProvider new] toJsonDict];
                    [dict ysfdt_setObject:jsonDict forKey:@"device"];
                }
                    break;
                case YSF_NIMDataTrackerConfigCategoryCarrier:
                {
                    NSDictionary *jsonDict = [[YSF_NIMCarrierInfoProvider new] toJsonDict];
                    [dict ysfdt_setObject:jsonDict forKey:@"carrier"];
                }
                    break;
                case YSF_NIMDataTrackerConfigCategoryApp:
                {
                    NSDictionary *jsonDict = [[YSF_NIMHostAppInfoProvider new] toJsonDict];
                    [dict ysfdt_setObject:jsonDict forKey:@"app"];
                }
                    break;
                case YSF_NIMDataTrackerConfigCategoryWifi:
                {
                    NSDictionary *jsonDict = [[YSF_NIMWifiInfoProvider new] toJsonDict];
                    [dict ysfdt_setObject:jsonDict forKey:@"wifi"];
                }
                    break;
                default:
                    break;
            }
        }
        
        for (NSString *key in customEvent.allKeys)
        {
            [dict ysfdt_setObject:customEvent[key]
                           forKey:key];
        }
        
    }
    if ([dict count])
    {
        postData = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    }
    else
    {
        YSFLogApp(@"ndtk refresh data empty");
    }
    if ([postData length])
    {
        YSFLogApp(@"ndtk refresh data : %@",[dict allKeys]);
        [self track:postData
         completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
             YSFLogApp(@"ndtk refresh data response %@",[self descriptionByResponse:response
                                                                                error:error]);
             self.inProgress = NO;
             if (error == nil &&
                 [response isKindOfClass:[NSHTTPURLResponse class]] &&
                 [(NSHTTPURLResponse *)response statusCode] == 200)
             {
                 
                 [self.config markCategoriesTracked:categories];
             }
         }];
    }
    else
    {
        self.inProgress = NO;
    }
}

#pragma mark - http request
- (void)refreshConfig
{
    NSDate *now = [NSDate date];
    if (_lastRefreshConfigDate && now && [now timeIntervalSinceDate:_lastRefreshConfigDate] < 3600 * 6)
    {
        YSFLogApp(@"ndtk refresh config cancelled because of in progress");
        return;
    }
    YSFLogApp(@"ndtk refresh config");
    NSString *urlString = [NSString stringWithFormat:@"%@/getConfig",NIM_DATA_TRACKER_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSDictionary *headers = [self.option headers];
    for (NSString *key in headers)
    {
        [request setValue:headers[key]
       forHTTPHeaderField:key];
    }
    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8"
   forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task =
    [self.session dataTaskWithRequest:request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        YSFLogApp(@"ndtk refresh config response %@",[self descriptionByResponse:response
                                                                                           error:error]);
                        if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
                            [(NSHTTPURLResponse *)response statusCode] == 200 &&
                            data &&
                            error == nil)
                        {
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:0
                                                                                       error:nil];
                            if ([jsonDict isKindOfClass:[NSDictionary class]])
                            {
                                self.config.serverConfig = jsonDict;
                                _lastRefreshConfigDate = [NSDate date];
                            }
                        }
                    }];
    [task resume];
}

- (void)track:(NSData *)postBody
      completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion
{
    //给云信服务器发
    NSString *urlString = [NSString stringWithFormat:@"%@/postData",NIM_DATA_TRACKER_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];
    NSDictionary *headers = [self.option headers];
    for (NSString *key in headers)
    {
        [request setValue:headers[key]
       forHTTPHeaderField:key];
    }
    [request setValue:@"application/json;charset=utf-8"
   forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task =
    [self.session dataTaskWithRequest:request
                    completionHandler: completion];
    [task resume];
    
    //给七鱼服务器发
    
}

- (id)descriptionByResponse:(NSURLResponse *)response
                      error:(NSError *)error
{
    return [response isKindOfClass:[NSHTTPURLResponse class]] ?
    @([(NSHTTPURLResponse *)response statusCode]) : error;
}


@end

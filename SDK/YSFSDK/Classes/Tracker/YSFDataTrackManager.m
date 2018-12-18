//
//  YSFDataTrackManager.m
//  YSFSDK
//
//  Created by liaosipei on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFDataTrackManager.h"
#import "YSFDataTrackRequest.h"

@implementation YSFDataTrackManager
#pragma mark - init
+ (instancetype)sharedManager {
    static YSFDataTrackManager *trackManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trackManager = [[YSFDataTrackManager alloc] init];
    });
    return trackManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - track
- (void)trackEventType:(YSFDataTrackEventType)type
                  data:(NSDictionary *)data
                shopId:(NSString *)shopId
             sessionId:(long long)sessionId {
    NSString *typeString = nil;
    switch (type) {
        case YSFDataTrackEventTypeBotDirectButton:
            typeString = @"ai_bot_direct_button_click";
            break;
            
        default:
            break;
    }
    if (!typeString.length) {
        return;
    }
    
    YSFDataTrackRequest *request = [[YSFDataTrackRequest alloc] init];
    request.type = typeString;
    request.sessionId = sessionId;
    request.jsonDict = data;
    if (shopId.length) {
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:shopId completion:^(NSError *error) {
            YSFLogApp(@"trackEvent:%@ error:%@", typeString, error);
        }];
    } else {
        [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
            YSFLogApp(@"trackEvent:%@ error:%@", typeString, error);
        }];
    }
    
}

@end

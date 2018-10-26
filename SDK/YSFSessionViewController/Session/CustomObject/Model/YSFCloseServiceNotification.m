//
//  YSFCloseService.m
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFCloseServiceNotification.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFCloseServiceNotification

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFCloseServiceNotification *instance = [[YSFCloseServiceNotification alloc] init];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.message = [dict ysf_jsonString:YSFApiKeyMessage];
    instance.closeReason = [dict ysf_jsonInteger:YSFApiKeyCloseReason];
    
    instance.evaluate  = [dict ysf_jsonBool:YSFApiKeyEvaluate];
    instance.autoPopup = [dict ysf_jsonBool:YSFApiKeyEvaluationAutoPopup];

    return instance;
}

@end

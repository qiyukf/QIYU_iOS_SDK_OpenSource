//
//  YSFInputtingStatus.m
//  YSFSDK
//
//  Created by liaosipei on 2019/4/2.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFInputtingStatus.h"
#import "YSFApiDefines.h"

@implementation YSFInputtingStatus

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFInputtingStatus *status = [[YSFInputtingStatus alloc] init];
    status.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    status.content = [dict ysf_jsonString:YSFApiKeyContent];
    return status;
}

@end

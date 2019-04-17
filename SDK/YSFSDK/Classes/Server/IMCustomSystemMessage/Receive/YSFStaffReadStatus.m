//
//  YSFStaffReadStatus.m
//  YSFSDK
//
//  Created by liaosipei on 2019/1/8.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFStaffReadStatus.h"
#import "YSFApiDefines.h"

@implementation YSFStaffReadStatus

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFStaffReadStatus *status = [[YSFStaffReadStatus alloc] init];
    status.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    status.timestamp = [dict ysf_jsonLongLong:YSFApiKeyTimestamp];
    return status;
}

- (NSDictionary *)toDict {
    NSDictionary *dict = @{
                           YSFApiKeySessionId : @(self.sessionId),
                           YSFApiKeyTimestamp : @(self.timestamp),
                           };
    return dict;
}

@end

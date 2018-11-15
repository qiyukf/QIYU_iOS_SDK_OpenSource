//
//  YSFRevokeMessageResult.m
//  YSFSDK
//
//  Created by liaosipei on 2018/10/16.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFRevokeMessageResult.h"
#import "YSFApiDefines.h"

@implementation YSFRevokeMessageResult

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFRevokeMessageResult *result = [[YSFRevokeMessageResult alloc] init];
    result.resultCode = [dict ysf_jsonInteger:YSFApiKeyResult];
    result.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    result.messageId = [dict ysf_jsonString:YSFApiKeyMsgIdClient];
    result.message = [dict ysf_jsonString:YSFApiKeyMessage];
    result.timestamp = [dict ysf_jsonLongLong:YSFApiKeyTimestamp];
    return result;
}

@end

//
//  YSFStartServiceObject.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFNewSession.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFNewSession

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]              = @(_command);
    dict[YSFApiKeyUserId]           = YSFStrParam(_userId);
    dict[YSFApiKeySessionId]        = @(_sessionId);
    dict[YSFApiKeyOldSessionId]     = @(_oldSessionId);
    dict[YSFApiKeyOldSessionType]   = @(_oldSessionType);
    
    return dict;
}

+ (YSFNewSession *)objectByDict:(NSDictionary *)dict
{
    YSFNewSession *instance = [[YSFNewSession alloc] init];
    instance.command                = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.userId                 = [dict ysf_jsonString:YSFApiKeyUserId];
    instance.sessionId              = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.oldSessionId           = [dict ysf_jsonLongLong:YSFApiKeyOldSessionId];
    instance.oldSessionType         = [dict ysf_jsonInteger:YSFApiKeyOldSessionType];
    return instance;
}

@end

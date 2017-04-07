//
//  YSFCommandWaitingStatus.m
//  YSFSDK
//
//  Created by panqinke on 10/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFQueryWaitingStatus.h"
#import "QYSDK_Private.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFQueryWaitingStatusRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd         :   @(YSFCommandWaitingStatusRequest),
                                       YSFApiKeyDeviceId    :   YSFStrParam([[QYSDK sharedSDK] deviceId])
                                    }];
    
    return params;
}

@end


@implementation YSFQueryWaitingStatusResponse

+ (YSFQueryWaitingStatusResponse *)dataByJson:(NSDictionary *)dict
{
    YSFQueryWaitingStatusResponse *instance     = [[YSFQueryWaitingStatusResponse alloc] init];
    instance.waitingNumber                = [dict ysf_jsonInteger:@"before"];
    instance.code                         = [dict ysf_jsonInteger:@"code"];
    instance.message                      = [dict ysf_jsonString:@"message"];
    instance.shopId = [dict ysf_jsonString:YSFApiKeyBId];
    instance.showNumber  = [dict ysf_jsonBool:YSFApiKeyShowNum];
    return instance;
}

@end

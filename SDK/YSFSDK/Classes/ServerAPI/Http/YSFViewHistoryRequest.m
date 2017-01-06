//
//  YSFViewHistoryAPI.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFViewHistoryRequest.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"

@interface YSFViewHistoryRequest ()

@end

@implementation YSFViewHistoryRequest

- (NSString *)apiPath
{
    NSString *apiAddress = [[[QYSDK sharedSDK] serverSetting] apiAddress];
    NSString *urlString = [apiAddress ysf_StringByAppendingApiPath:@"/webapi/user/accesshistory.action"];
    return urlString;
}

- (NSDictionary *)params
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyURI]                = YSFStrParam(_urlString);
    dict[YSFApiKeyDeviceId]           = YSFStrParam([[QYSDK sharedSDK] deviceId]);
    dict[YSFApiKeyAppKey]             = YSFStrParam([[QYSDK sharedSDK] appKey]);

    if (_attributes) {
        [dict addEntriesFromDictionary:[_attributes ysf_formattedDict]];

    }
    return dict;
}

- (id)dataByJson:(NSDictionary *)json
           error:(NSError **)error;
{
    return nil;
}

@end

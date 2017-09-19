//
//  YSFCustomServiceRequest.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFRequestServiceRequest.h"
#import "QYSDK_Private.h"
#import "QYSource.h"


@implementation YSFRequestServiceRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    int intOnlyManual = _onlyManual;
    int intOpenRobotInShuntMode = _openRobotInShuntMode;

    //基本信息
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd         :   @(YSFCommandRequestServiceRequest),
                                       YSFApiKeyDeviceId    :   YSFStrParam([[QYSDK sharedSDK] deviceId]),
                                       YSFApiKeyExchange    :   @"-1",
                                       YSFApiKeyFromType    :   YSFApiValueIOS,
                                       YSFApiKeyFromSubType :   [[UIDevice currentDevice] systemVersion],
                                       YSFApiKeyStaffType   :   @(intOnlyManual),
                                       YSFApiKeyVersion     :   @"33",
                                       YSFApiKeyStaffId     :   @(_staffId),
                                       YSFApiKeyGroupId     :   @(_groupId),
                                       YSFApiKeyEntryId     :   @(_entryId),
                                       YSFApiKeyRobotShuntSwitch : @(intOpenRobotInShuntMode),
                                       YSFApiKeyCommonQuestionTemplateId  :  @(_commonQuestionTemplateId),
                                       YSFApiKeyLevel  :  @(_vipLevel),
                                       }];
    
    //附带信息
    if ([_source.title length]) {
        [params setObject:_source.title forKey:YSFApiKeyFromTitle];
    }
    if ([_source.urlString length]) {
        [params setObject:_source.urlString forKey:YSFApiKeyFromPage];
    }
    if ([_source.customInfo length]) {
        [params setObject:_source.customInfo forKey:YSFApiKeyFromCustom];
    }
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId length]) {
        [params setObject:bundleId forKey:YSFApiKeyFromBundleId];
    }
    NSString *ip = [[YSF_NIMSDK sharedSDK] currentIp];
    if ([ip length])
    {
        [params setObject:ip forKey:YSFApiKeyFromIp];
    }
    
    return params;
}

@end

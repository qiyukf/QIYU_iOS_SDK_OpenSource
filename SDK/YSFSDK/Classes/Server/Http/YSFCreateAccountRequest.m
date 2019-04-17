//
//  YSFCreateAccountAPI.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFCreateAccountRequest.h"
#import "YSFAccountInfo.h"
#import "NSDictionary+YSFJson.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"

@implementation YSFCreateAccountRequest

- (NSString *)apiPath {
    NSString *apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
    NSString *urlString = [apiAddress ysf_StringByAppendingApiPath:@"/webapi/user/create.action"];
    return urlString;
}

- (NSDictionary *)params {
    NSDictionary *dict = @{ YSFApiKeyAppKey : YSFStrParam([[QYSDK sharedSDK] appKey]),
                            YSFApiKeyDeviceId : YSFStrParam([[QYSDK sharedSDK] deviceId]),
                            YSFApiKeyForeignId : YSFStrParam(self.foreignID),
                            YSFApiKeyCRMInfo : YSFStrParam(self.crmInfo),
                            YSFApiKeyAuthToken : YSFStrParam(self.authToken),
                            };
    return dict;
}

- (id)dataByJson:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    NSError *parseError = nil;
    YSFAccountInfo *info = nil;
    
    NSInteger code = [json ysf_jsonInteger:YSFApiKeyCode];
    if (code == 200) {
        NSDictionary *jsonInfo = [json ysf_jsonDict:YSFApiKeyInfo];
        YSFAccountInfo *appInfo = [YSFAccountInfo infoByDict:jsonInfo];
        if ([appInfo isValid]) {
            info = appInfo;
        } else {
            parseError = [NSError errorWithDomain:YSFErrorDomain code:YSFCodeInvalidData userInfo:nil];
        }
    } else {
        parseError = [NSError errorWithDomain:YSFErrorDomain code:code userInfo:nil];
    }
    
    YSFLogApp(@"YSFCreateAccountRequest result: %@",parseError);
    
    if (error) {
        *error = parseError;
    }
    return info;
}


@end

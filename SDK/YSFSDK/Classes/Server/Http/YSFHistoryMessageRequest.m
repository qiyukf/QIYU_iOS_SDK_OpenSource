//
//  YSFHistoryMessageRequest.m
//  YSFSDK
//
//  Created by liaosipei on 2019/2/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFHistoryMessageRequest.h"
#import "NSDictionary+YSFJson.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"

@implementation YSFHistoryMessageRequest
- (NSString *)apiPath {
    NSString *apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
    NSString *urlString = [apiAddress ysf_StringByAppendingApiPath:@"/webapi/sdk/user/message/history"];
    return urlString;
}

- (NSDictionary *)params {
    NSDictionary *dict = @{ YSFApiTolerantKeyAppKey : YSFStrParam([[QYSDK sharedSDK] appKey]),
                            YSFApiKeyFromAccount : YSFStrParam([[QYSDK sharedSDK].infoManager currentUserId]),
                            YSFApiKeyAccessToken : YSFStrParam(self.token),
                            YSFApiKeyBeginTime : [NSString stringWithFormat:@"%lld", self.beginTime],
                            YSFApiKeyEndTime : [NSString stringWithFormat:@"%lld", self.endTime],
                            YSFApiKeyLimit : [NSString stringWithFormat:@"%lu", (unsigned long)self.limit],
                            };
    return dict;
}

- (id)dataByJson:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    NSError *parseError = nil;
    NSArray *messages = nil;
    
    NSInteger code = [json ysf_jsonInteger:YSFApiKeyCode];
    if (code == 200) {
        messages = [json ysf_jsonArray:YSFApiKeyResult];
    } else {
        parseError = [NSError errorWithDomain:YSFErrorDomain code:code userInfo:nil];
    }
    
    if (error) {
        *error = parseError;
    }
    return messages;
}


@end

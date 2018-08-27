

#import "YSFDARequest.h"
#import "YSFAccountInfo.h"
#import "NSDictionary+YSFJson.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"
#import "NSArray+YSF.h"

@implementation YSFDARequest

- (NSString *)apiPath {
    NSString *urlString = [NSString stringWithFormat:@"http://da.%@/mobileda/da.gif", [QYSDK sharedSDK].serverAddress];
    NSString *appKey = [[YSF_NIMSDK sharedSDK] appKey];
    NSString *deviceId;
    if ([[QYSDK sharedSDK].infoManager currentForeignUserId].length > 0) {
        deviceId = [[QYSDK sharedSDK].infoManager currentForeignUserId];
    } else {
        deviceId = [[QYSDK sharedSDK] deviceId];
    }
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *base64String = @"";
    for (int i = 0; i < _array.count; i++) {
        if (i >= 1) {
            base64String = [base64String stringByAppendingString:@","];
        }
        NSDictionary *dict = _array[i];
        NSString *dataString = nil;
        NSString *title = [dict objectForKey:YSFDARequestTitleKey];
        NSString *time = [dict objectForKey:YSFDARequestTimeKey];
        NSString *key = [dict objectForKey:YSFDARequestKeyKey];
        NSString *type = [dict objectForKey:YSFDARequestTypeKey];
        NSString *cup = title;
        dataString = @"ak=%@&dv=%@&cup=%@&tm=%@&ct=%@&lt=%@&tp=%@&desc=%@&u=%@";
        if ([type isEqualToString:@"0"]) {
            //访问轨迹
            NSString *enterOrOut = [dict objectForKey:YSFDARequestEnterOrOutKey];
            dataString = [NSString stringWithFormat:dataString, appKey, deviceId, cup, time, title, enterOrOut, type, @"", key];
        } else if ([type isEqualToString:@"1"]) {
            //行为轨迹
            NSString *description = [dict objectForKey:YSFDARequestDescriptionKey];
            description = description ? description : @"";
            dataString = [NSString stringWithFormat:dataString, appKey, deviceId, cup, time, title, @"", type, description, key];
        }
        if (dataString.length) {
            NSData *encodeData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            base64String = [base64String stringByAppendingString:[encodeData base64EncodedStringWithOptions:0]];
        }
    }
    urlString = [urlString stringByAppendingString:@"?ak=%@&bid=%@&r=%@"];
    urlString = [NSString stringWithFormat:urlString, appKey, bundleId, base64String];

    return urlString;
}

- (NSDictionary *)params {
    return nil;
}

- (id)dataByJson:(NSDictionary *)json
           error:(NSError *__autoreleasing *)error {
    NSError *parseError = nil;
    YSFAccountInfo *info = nil;
    
    NSInteger code = [json ysf_jsonInteger:YSFApiKeyCode];
    if (code == 200) {
        NSDictionary *jsonInfo = [json ysf_jsonDict:YSFApiKeyInfo];
        
        YSFAccountInfo *appInfo = [YSFAccountInfo infoByDict:jsonInfo];
        if ([appInfo isValid]) {
            info = appInfo;
        } else {
            parseError = [NSError errorWithDomain:YSFErrorDomain
                                        code:YSFCodeInvalidData
                                    userInfo:nil];
        }
    } else {
        parseError = [NSError errorWithDomain:YSFErrorDomain
                                    code:code
                                userInfo:nil];
    }
    
    YSFLogApp(@"YSFCreateAccountRequest result: %@",parseError);
    
    if (error) {
        *error = parseError;
    }
    return info;
}


@end

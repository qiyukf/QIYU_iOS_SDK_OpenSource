//
//  YSFMessageFormRequest.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormRequest.h"
#import "YSFMessageFormField.h"
#import "NSDictionary+YSFJson.h"
#import "QYSDK_Private.h"
#import "YSFApiDefines.h"

@implementation YSFMessageFormRequest
- (NSString *)apiPath {
    NSString *apiAddress = [[YSFServerSetting sharedInstance] apiAddress];
    NSString *urlString = [apiAddress ysf_StringByAppendingApiPath:@"/webapi/user/getLeaveCustomfield"];
    return urlString;
}

- (NSDictionary *)params {
    NSDictionary *dict = @{ YSFApiKeyAppKey : YSFStrParam([[QYSDK sharedSDK] appKey]),
                            YSFApiKeyBId : YSFStrParam(self.shopId),
                            };
    return dict;
}

- (id)dataByJson:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    NSError *parseError = nil;
    NSMutableArray *result = nil;
    
    NSInteger code = [json ysf_jsonInteger:YSFApiKeyCode];
    if (code == 200) {
        NSArray *array = [json ysf_jsonArray:YSFApiKeyResult];
        if (array && [array isKindOfClass:[NSArray class]]) {
            result = [NSMutableArray arrayWithCapacity:[array count]];
            for (NSDictionary *dict in array) {
                YSFMessageFormField *field = [YSFMessageFormField dataByJson:dict];
                if (field) {
                    [result addObject:field];
                }
            }
        } else {
            parseError = [NSError errorWithDomain:YSFErrorDomain code:YSFCodeInvalidData userInfo:nil];
        }
    } else {
        parseError = [NSError errorWithDomain:YSFErrorDomain code:code userInfo:nil];
    }
    
    if (error) {
        *error = parseError;
    }
    return result;
}

@end

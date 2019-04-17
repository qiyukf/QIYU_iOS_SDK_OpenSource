//
//  YSFEmoticonListRequest.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonListRequest.h"
#import "YSFServerSetting.h"
#import "YSFApiDefines.h"
#import "NIMSDK.h"

@implementation YSFEmoticonListRequest
- (NSString *)apiPath {
    NSString *apiDomain = [[YSFServerSetting sharedInstance] apiAddress];
    apiDomain = [apiDomain ysf_StringByAppendingApiPath:@"webapi/emoji/emojiPackage/get?k=%@"];
    NSString *urlStr = [NSString stringWithFormat:apiDomain, YSFStrParam([[YSF_NIMSDK sharedSDK] appKey])];
    return urlStr;
}

- (NSDictionary *)params {
    return nil;
}

- (id)dataByJson:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    NSError *parseError = nil;
    NSArray *packages = [NSArray array];
    
    NSInteger code = [json ysf_jsonInteger:YSFApiKeyCode];
    if (code == YSFCodeSuccess) {
        packages = [json ysf_jsonArray:YSFApiKeyResult];
    } else {
        parseError = [NSError errorWithDomain:YSFErrorDomain code:code userInfo:nil];
    }
    
    YSFLogApp(@"YSFEmoticonListRequest result: %@", parseError);
    
    if (error) {
        *error = parseError;
    }
    return packages;
}

@end

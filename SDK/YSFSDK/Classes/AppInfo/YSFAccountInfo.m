//
//  YSFAppInfo.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAccountInfo.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFAccountInfo
+ (instancetype)infoByDict:(NSDictionary *)dict {
    YSFAccountInfo *instance = [[YSFAccountInfo alloc] init];
    instance.accid = [dict ysf_jsonString:@"accid"];
    instance.token = [dict ysf_jsonString:@"token"];
    instance.isEverLogined = [dict ysf_jsonBool:@"ysf_ever_logined"];
    instance.bid = [dict ysf_jsonString:@"bid"];
    if (instance.bid.length == 0) {
        instance.bid = @"-1";
    }
    return instance;
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self isValid]) {
        [dict setValue:_accid forKey:@"accid"];
        [dict setValue:_token forKey:@"token"];
        [dict setValue:@(_isEverLogined) forKey:@"ysf_ever_logined"];
        [dict setValue:YSFStrParam(_bid) forKey:@"bid"];
    } else {
        YSFLogErr(@"invalid app info");
    }
    return dict;
}

- (BOOL)isValid {
    return [_accid length] && [_token length] && [_bid length];
}

- (BOOL)isPop {
    return ![_bid isEqualToString:@"-1"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[YSFAccountInfo class]]) {
        YSFAccountInfo *info = (YSFAccountInfo *)object;
        if ([info.accid isEqualToString:self.accid]) {
            return YES;
        }
    }
    return NO;
}

@end

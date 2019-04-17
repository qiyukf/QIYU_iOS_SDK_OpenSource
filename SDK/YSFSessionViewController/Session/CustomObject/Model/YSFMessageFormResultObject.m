//
//  YSFMessageFormResultObject.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormResultObject.h"
#import "NSArray+YSF.h"
#import "YSFApiDefines.h"
#import "YSFMessageFormResultContentConfig.h"

@implementation YSFMessageFormResultObject

- (NSString *)thumbText {
    return @"[留言消息]";
}

- (YSFMessageFormResultContentConfig *)contentConfig {
    return [[YSFMessageFormResultContentConfig alloc] init];
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(YSFCommandMessageFormResultCard);
    dict[YSFApiKeyTitle] = YSFStrParam(_title);
    if ([_fields count]) {
        dict[YSFApiKeyResult] = YSFStrParam([_fields ysf_toUTF8String]);
    }
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFMessageFormResultObject *object = [[YSFMessageFormResultObject alloc] init];
    object.command = [dict ysf_jsonLongLong:YSFApiKeyCmd];
    object.title = [dict ysf_jsonString:YSFApiKeyTitle];
    NSString *json = [dict ysf_jsonString:YSFApiKeyResult];
    object.fields = [json ysf_toArray];
    return object;
}

@end

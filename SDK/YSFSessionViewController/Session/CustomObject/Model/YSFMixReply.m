//
//  YSFMixReply.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/8/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMixReply.h"
#import "YSFMixReplyContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"

@implementation YSFMixReply

- (NSString *)thumbText {
    return @"[查询消息]";
}

- (YSFMixReplyContentConfig *)contentConfig {
    return [[YSFMixReplyContentConfig alloc] init];
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFMixReply *instance = [[YSFMixReply alloc] init];
    instance.label = [dict ysf_jsonString:YSFApiKeyLabel];
    NSArray *list = [dict ysf_jsonArray:YSFApiKeyList];
    NSMutableArray *mutableList = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableList addObject:[YSFAction objectByDict:obj]];
    }];
    instance.actionList = mutableList;
    return instance;
}

@end

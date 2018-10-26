//
//  YSFEvaluationResult.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/10/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFEvaluationResult.h"
#import "YSFApiDefines.h"

@implementation YSFEvaluationResult

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFEvaluationResult *result = [[YSFEvaluationResult alloc] init];
    result.code = [dict ysf_jsonInteger:YSFApiKeyBody];
    result.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    result.desc = [dict objectForKey:YSFApiKeyDesc];
    return result;
}

@end

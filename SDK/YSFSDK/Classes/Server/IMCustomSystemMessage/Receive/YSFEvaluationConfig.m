//
//  YSFEvaluationConfig.m
//  YSFSDK
//
//  Created by liaosipei on 2019/1/11.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEvaluationConfig.h"
#import "YSFApiDefines.h"

@implementation YSFEvaluationConfig

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFEvaluationConfig *config = [[YSFEvaluationConfig alloc] init];
    return config;
}

- (NSDictionary *)toDict {
    NSDictionary *dict = @{
                           
                           };
    return dict;
}

@end

//
//  YSFMessageFormResponse.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormResponse.h"
#import "YSFApiDefines.h"

@implementation YSFMessageFormResponse

+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFMessageFormResponse *response = [[YSFMessageFormResponse alloc] init];
    response.auditResult = [dict ysf_jsonInteger:YSFApiKeyAuditResult];
    return response;
}

@end

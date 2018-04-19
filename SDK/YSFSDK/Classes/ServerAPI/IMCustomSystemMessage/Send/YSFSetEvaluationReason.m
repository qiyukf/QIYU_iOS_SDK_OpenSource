//
//  YSFSetEvaluationReason.m
//  YSFSDK
//
//  Created by Jacky Yu on 2018/3/2.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFSetEvaluationReasonRequest.h"

@implementation YSFSetEvaluationReasonRequest

- (NSDictionary *)toDict {
    return @{
             YSFApiKeyCmd : @(YSFCommandEvaluationReason),
             YSFApiKeyMsgIdClient : YSFStrParam(_msgId),
             YSFApiKeyEvaluationContent : YSFStrParam(_evaluationContent)
             };
}

@end

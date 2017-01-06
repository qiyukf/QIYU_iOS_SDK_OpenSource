//
//  YSFMachineResponse.m
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFMachineResponse.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"


@implementation YSFMachineResponse

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyQuestion]          = YSFStrParam(_originalQuestion);
    dict[YSFApiKeyAnswerType]        = @(_answerType);
    dict[YSFApiKeyOperatorHint]      = @(_operatorHint);
    dict[YSFApiKeyOperatorHintDesc]  = YSFStrParam(_operatorHintDesc);
    
    if (_answerArray) {
        NSData *arrayData = [NSJSONSerialization dataWithJSONObject:_answerArray
                                                            options:0
                                                              error:nil];
        if (arrayData)
        {
            dict[YSFApiKeyAnswerList]  = [[NSString alloc] initWithData:arrayData
                                                               encoding:NSUTF8StringEncoding];
        }
    }
    
    dict[YSFApiKeyAnswerLabel]  = YSFStrParam(_answerLabel);
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFMachineResponse *instance = [[YSFMachineResponse alloc] init];
    instance.command             = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.originalQuestion = [dict ysf_jsonString:YSFApiKeyQuestion];
    if (!instance.originalQuestion) {
        instance.originalQuestion = @"";
    }
    instance.answerType = [dict ysf_jsonInteger:YSFApiKeyAnswerType];
    instance.operatorHint = [dict ysf_jsonBool:YSFApiKeyOperatorHint];
    instance.operatorHintDesc = [dict ysf_jsonString:YSFApiKeyOperatorHintDesc];
    if (!instance.operatorHintDesc) {
        instance.operatorHintDesc = @"";
    }
    NSString *answerList = [dict ysf_jsonString:YSFApiKeyAnswerList];
    if (answerList) {
        instance.answerArray = [answerList ysf_toArray];
    }
    
    instance.answerLabel = [dict ysf_jsonString:YSFApiKeyAnswerLabel];
    if (!instance.answerLabel) {
        instance.answerLabel = @"";
    }
    if (instance.answerArray && instance.answerArray.count == 1 && [instance.answerLabel isEqualToString:@""]) {
        instance.isOneQuestionRelevant = NO;
    }
    else {
        instance.isOneQuestionRelevant = YES;
    }
    
    return instance;
}

@end

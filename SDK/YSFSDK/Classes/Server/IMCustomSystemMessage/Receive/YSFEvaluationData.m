//
//  YSFEvaluationData.m
//  YSFSDK
//
//  Created by liaosipei on 2018/11/20.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFEvaluationData.h"
#import "YSFApiDefines.h"

@implementation YSFEvaluationTag

+ (instancetype)dataByDict:(NSDictionary *)dict {
    YSFEvaluationTag *tag = [[YSFEvaluationTag alloc] init];
    tag.name = [dict ysf_jsonString:YSFApiKeyName];
    if ([tag.name isEqualToString:@"非常满意"]) {
        tag.type = YSFEvaluationTagTypeVerySatisfied;
    } else if ([tag.name isEqualToString:@"满意"]) {
        tag.type = YSFEvaluationTagTypeSatisfied;
    } else if ([tag.name isEqualToString:@"一般"]) {
        tag.type = YSFEvaluationTagTypeOrdinary;
    } else if ([tag.name isEqualToString:@"不满意"]) {
        tag.type = YSFEvaluationTagTypeDissatisfied;
    } else if ([tag.name isEqualToString:@"非常不满意"]) {
        tag.type = YSFEvaluationTagTypeVeryDissatisfied;
    } else {
        tag.type = YSFEvaluationTagTypeNone;
    }
    tag.score = [dict ysf_jsonInteger:YSFApiKeyValue];
    tag.tagList = [dict ysf_jsonStringArray:YSFApiKeyTagList];
    tag.tagRequired = [dict ysf_jsonBool:YSFApiKeyEvaluationTagRequired];
    tag.commentRequired = [dict ysf_jsonBool:YSFApiKeyEvaluationCommentRequired];
    return tag;
}

@end

@implementation YSFEvaluationData

+ (instancetype)dataByDict:(NSDictionary *)dict {
    YSFEvaluationData *data = [[YSFEvaluationData alloc] init];
    data.type = [dict ysf_jsonInteger:YSFApiKeyType];
    data.scoreType = [dict ysf_jsonInteger:YSFApiKeyEvaluationScoreType];
    data.webAppSort = [dict ysf_jsonBool:YSFApiKeyEvaluationWebAppSort];
    data.wxwbSort = [dict ysf_jsonBool:YSFApiKeyEvaluationWxWbSort];
    data.title = [dict ysf_jsonString:YSFApiKeyTitle];
    data.note = [dict ysf_jsonString:YSFApiKeyNote];
    data.inviteText = [dict ysf_jsonString:YSFApiKeyEvaluationInviteMsg];
    data.thanksText = [dict ysf_jsonString:YSFApiKeyEvaluationThanksMsg];
    NSArray *array = [dict ysf_jsonArray:YSFApiKeyList];
    if (array && array.count) {
        NSMutableArray *tagArray = [NSMutableArray array];
        for (NSDictionary *tagDict in array) {
            YSFEvaluationTag *tag = [YSFEvaluationTag dataByDict:tagDict];
            [tagArray addObject:tag];
        }
        //webAppSort:0 —— 满意到不满意的升序，ascending = YES
        //webAppSort:1 —— 不满意到满意的降序，ascending = NO
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:!data.webAppSort];
        NSArray *sortedArray = [tagArray sortedArrayUsingDescriptors:@[descriptor]];
        data.tagArray = sortedArray;
    }
    return data;
}

+ (instancetype)makeDefaultData {
    YSFEvaluationData *data = [[YSFEvaluationData alloc] init];
    YSFEvaluationTag *tag1 = [[YSFEvaluationTag alloc] init];
    tag1.name = @"满意";
    tag1.score = 100;
    
    YSFEvaluationTag *tag2 = [[YSFEvaluationTag alloc] init];
    tag2.name = @"不满意";
    tag2.score = 1;
    
    data.tagArray = @[tag1, tag2];
    return data;
}

@end

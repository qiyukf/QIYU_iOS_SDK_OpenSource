
//
//  YSFSession.m
//  YSFSDK
//
//  Created by amao on 8/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFServiceSession.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFShopInfo.h"
#import "YSFActionBar.h"

@implementation YSFServiceSession
- (NSString *)description {
    return [NSString stringWithFormat:@"service session sid %@ session id %lld staffid %@ staffname %@ code %zd",
            _serviceId,_sessionId,_staffId,_staffName,_code];
}

- (BOOL)isEqual:(id)object {
    BOOL result = NO;
    if ([object isKindOfClass:[YSFServiceSession class]]) {
        NSString *serviceId = [(YSFServiceSession *)object serviceId];
        long long sessionId = [(YSFServiceSession *)object sessionId];
        result = _serviceId && _sessionId && [_serviceId isEqualToString:serviceId] && _sessionId == sessionId;
    }
    return result;
}

+ (YSFServiceSession *)dataByJson:(NSDictionary *)dict {
    YSFServiceSession *instance = [[YSFServiceSession alloc] init];
    instance.serviceId = [dict ysf_jsonString:YSFApiKeyExchange];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.staffId = [dict ysf_jsonString:YSFApiKeyStaffId];
    instance.realStaffId = [dict ysf_jsonLongLong:YSFApiKeyRealStaffId];
    instance.groupId = [dict ysf_jsonLongLong:YSFApiKeyGroupId];
    instance.staffName = [dict ysf_jsonString:YSFApiKeyStaffName];
    instance.iconUrl = YSFStrParam([dict ysf_jsonString:YSFApiKeyIconUrl]);
    instance.before = [dict ysf_jsonInteger:YSFApiKeyBefore];
    instance.lastServiceTime = [NSDate date];
    instance.code = [dict ysf_jsonInteger:YSFApiKeyCode];
    instance.operatorEable = [dict ysf_jsonInteger:YSFApiKeyOperatorEnable];
    instance.message = [dict ysf_jsonString:YSFApiKeyMessage];
    instance.inQueeuNotify = [dict ysf_jsonString:YSFApiKeyInqueueNotify];
    instance.showNumber = [dict ysf_jsonBool:YSFApiKeyShowNum];
    instance.robotInQueue = [dict ysf_jsonBool:YSFApiKeyRobotInQueue];
    instance.robotSessionId = [dict ysf_jsonLongLong:YSFApiKeyRobotSessionId];

    NSMutableDictionary *evaluationDict = [NSMutableDictionary new];
    NSString *evaluation = [dict ysf_jsonString:YSFApiKeyEvaluation];
    if (evaluation) {
        NSDictionary *dictEvaluation = [evaluation ysf_toDict];
        NSArray *arrayEvaluation = [dictEvaluation ysf_jsonArray:YSFApiKeyList];
        for (NSDictionary *dict in arrayEvaluation) {
            NSString *name = [dict ysf_jsonString:YSFApiKeyName];
            if (name) {
                [evaluationDict setValue:dict forKey:name];
            }
        }
        instance.messageInvite = [dictEvaluation ysf_jsonString:YSFApiKeyEvaluationMessageInvite];
        instance.messageThanks = [dictEvaluation ysf_jsonString:YSFApiKeyEvaluationMessageThanks];
    }
    instance.evaluation = evaluationDict;
    
    NSInteger staffType = [dict ysf_jsonInteger:YSFApiKeyStaffType];
    if (staffType == 0) {
        instance.humanOrMachine = YES;
    } else {
        instance.humanOrMachine = NO;
    }
    
    NSArray *bot = [dict ysf_jsonArray:YSFApiKeyBot];
    NSMutableArray *actionInfoArray = [NSMutableArray arrayWithCapacity:bot.count];
    for (NSDictionary *dict in bot) {
        YSFActionInfo *actionInfo = [YSFActionInfo dataByJson:dict];
        [actionInfoArray addObject:actionInfo];
    }
    instance.actionInfoArray = actionInfoArray;
    
    NSDictionary *shopInfoDict = [dict ysf_jsonDict:YSFApiKeyShop];
    if (shopInfoDict) {
        instance.shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
    }
    
    return instance;
}

- (BOOL)canOfferService {
    NSDate *now = [NSDate date];
    return fabs([now timeIntervalSinceDate:_lastServiceTime]) <= 5 * 60;
}

@end

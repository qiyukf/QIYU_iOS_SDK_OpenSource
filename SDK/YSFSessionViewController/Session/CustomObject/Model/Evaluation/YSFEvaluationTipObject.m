//
//  YSFEvaluationTipObject.m
//  YSFSDK
//
//  Created by towik on 1/24/16.
//  Copyright (c) 2016 Netease. All rights reserved.
//

#import "YSFEvaluationTipObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFEvaluationTipObject
- (NSString *)thumbText {
    NSString *text = @"";
    if (_specialThanksTip.length) {
        text = _specialThanksTip;
    } else {
        text = [NSString stringWithFormat:@"[%@%@]", _tipContent, _tipResult];
    }
    return text;
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeySessionId] = @(_sessionId);
    dict[YSFApiKeyTipContent] = YSFStrParam(_tipContent);
    dict[YSFApiKeyTipResult] = YSFStrParam(_tipResult);
    dict[YSFApiKeyTipModify] = YSFStrParam(_tipModify);
    dict[YSFApiKeyKaolaTipResult] = YSFStrParam(_specialThanksTip);
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFEvaluationTipObject *instance = [[YSFEvaluationTipObject alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.sessionId = [dict ysf_jsonLongLong:YSFApiKeySessionId];
    instance.tipContent = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipContent]);
    instance.tipResult = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipResult]);
    instance.tipModify = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipModify]);
    instance.specialThanksTip = YSFStrParam([dict ysf_jsonString:YSFApiKeyKaolaTipResult]);
    return instance;
}
@end

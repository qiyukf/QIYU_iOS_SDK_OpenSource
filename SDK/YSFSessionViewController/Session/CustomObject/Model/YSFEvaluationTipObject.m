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

- (NSString *)thumbText
{
    NSString *text = @"";
    if (_kaolaTipContent.length) {
        text = _kaolaTipContent;
    } else {
        text = [NSString stringWithFormat:@"[%@%@]", _tipContent, _tipResult];
    }
    
    return text;
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]          = @(_command);
    dict[YSFApiKeyTipContent]      = YSFStrParam(_tipContent);
    dict[YSFApiKeyTipResult]      = YSFStrParam(_tipResult);
    dict[YSFApiKeyKaolaTipResult]      = YSFStrParam(_kaolaTipContent);

    return dict;
}

+ (YSFEvaluationTipObject *)objectByDict:(NSDictionary *)dict
{
    YSFEvaluationTipObject *instance = [[YSFEvaluationTipObject alloc] init];
    instance.command                = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.tipContent             = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipContent]);
    instance.tipResult             = YSFStrParam([dict ysf_jsonString:YSFApiKeyTipResult]);
    instance.kaolaTipContent             = YSFStrParam([dict ysf_jsonString:YSFApiKeyKaolaTipResult]);

    return instance;
}
@end

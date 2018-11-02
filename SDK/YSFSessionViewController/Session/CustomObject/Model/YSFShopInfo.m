//
//  YSFShopInfo.m
//  YSFSDK
//
//  Created by JackyYu on 2016/12/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFShopInfo.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"


@implementation YSFShopInfo

- (NSDictionary *)toDict
{
    NSDictionary *params =  @{
                              YSFApiKeyId     :   YSFStrParam(_shopId),
                              YSFApiKeyName   :   YSFStrParam(_name),
                              YSFApiKeyLogo   :   YSFStrParam(_logo),
                              };
    return params;
}

+ (instancetype)instanceByJson:(NSDictionary *)json
{
    YSFShopInfo *shopInfo = [YSFShopInfo new];
    shopInfo.shopId = [json ysf_jsonString:YSFApiKeyId];
    shopInfo.name = [json ysf_jsonString:YSFApiKeyName];
    shopInfo.logo = [json ysf_jsonString:YSFApiKeyLogo];
    
    return shopInfo;
}


@end

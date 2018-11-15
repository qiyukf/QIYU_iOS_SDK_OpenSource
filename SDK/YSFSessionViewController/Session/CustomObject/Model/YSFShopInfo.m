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

@implementation YSFShopSettingInfo

+ (instancetype)instanceByJson:(NSDictionary *)json {
    YSFShopSettingInfo *setting = [[YSFShopSettingInfo alloc] init];
    setting.sessionOpenSwitch = [json ysf_jsonBool:YSFApiKeySessionOpenSwitch];
    setting.sessionEndSwitch = [json ysf_jsonBool:YSFApiKeySessionEndSwitch];
    setting.sessionTimeoutSwitch = [json ysf_jsonBool:YSFApiKeySessionTimeoutSwitch];
    setting.staffReadSwitch = [json ysf_jsonBool:YSFApiKeyStaffReadSwitch];
    setting.inputSwitch = [json ysf_jsonBool:YSFApiKeyInputSwitch];
    setting.sendingRate = [json ysf_jsonDouble:YSFApiKeySendingRate];
    setting.multEvaluationEnable = [json ysf_jsonBool:YSFApiKeyEvaluationModifyEnable];
    setting.evaluationTimeLimit = [json ysf_jsonInteger:YSFApiKeyEvaluationModifyTimeout];
    return setting;
}

- (NSDictionary *)toDict {
    NSDictionary *dict = @{
                           YSFApiKeySessionOpenSwitch : @(self.sessionOpenSwitch),
                           YSFApiKeySessionEndSwitch : @(self.sessionEndSwitch),
                           YSFApiKeySessionTimeoutSwitch : @(self.sessionTimeoutSwitch),
                           YSFApiKeyStaffReadSwitch : @(self.staffReadSwitch),
                           YSFApiKeyInputSwitch : @(self.inputSwitch),
                           YSFApiKeySendingRate : @(self.sendingRate),
                           YSFApiKeyEvaluationModifyEnable : @(self.multEvaluationEnable),
                           YSFApiKeyEvaluationModifyTimeout : @(self.evaluationTimeLimit),
                           };
    return dict;
}

@end


@implementation YSFShopInfo

+ (instancetype)instanceByJson:(NSDictionary *)json {
    YSFShopInfo *shopInfo = [[YSFShopInfo alloc] init];
    shopInfo.shopId = [json ysf_jsonString:YSFApiKeyId];
    shopInfo.name = [json ysf_jsonString:YSFApiKeyName];
    shopInfo.logo = [json ysf_jsonString:YSFApiKeyLogo];
    
    shopInfo.hasEmail = [json ysf_jsonBool:YSFApiKeyHasEmail];
    shopInfo.hasMobile = [json ysf_jsonBool:YSFApiKeyHasMobile];
    shopInfo.qiyuInfoSwitch = [json ysf_jsonBool:YSFApiKeyQYInfoSwitch];
    NSDictionary *setting = [json ysf_jsonDict:YSFApiKeySetting];
    if (setting) {
        shopInfo.setting = [YSFShopSettingInfo instanceByJson:setting];
    }
    
    return shopInfo;
}

- (NSDictionary *)toDict {
    NSDictionary *params =  @{
                              YSFApiKeyId : YSFStrParam(_shopId),
                              YSFApiKeyName : YSFStrParam(_name),
                              YSFApiKeyLogo : YSFStrParam(_logo),
                              };
    return params;
}

@end

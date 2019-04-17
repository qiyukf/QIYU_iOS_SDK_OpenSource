//
//  YSFMessageFormResult.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormResult.h"
#import "QYSDK_Private.h"

@implementation YSFMessageFormResult

- (NSDictionary *)toDict {
    return @{
             YSFApiKeyCmd : @(YSFCommandMessageFormRequest),
             YSFApiKeyDeviceId : YSFStrParam([[QYSDK sharedSDK] deviceId]),
             YSFApiKeyBId : YSFStrParam(self.shopId),
             YSFApiKeyMessage : YSFStrParam(self.message),
             YSFApiKeyMobile : YSFStrParam(self.mobile),
             YSFApiKeyEmail : YSFStrParam(self.email),
             YSFApiKeyCustomFields : YSFStrParam(self.customFields),
              };
}

@end

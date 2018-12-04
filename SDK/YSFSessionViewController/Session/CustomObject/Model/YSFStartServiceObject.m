//
//  YSFStartServiceObject.m
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFStartServiceObject.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"


@implementation YSFStartServiceObject

- (NSString *)thumbText {
    NSString *text = [NSString stringWithFormat:@"[客服%@为您服务]", _staffName];
    return text;
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeyStaffId] = YSFStrParam(_staffId);
    dict[YSFApiKeyIconUrl] = YSFStrParam(_iconUrl);
    dict[YSFApiKeyStaffName] = YSFStrParam(_staffName);
    dict[YSFApiKeyGroupName] = YSFStrParam(_groupName);
    dict[YSFApiKeyMessage] = YSFStrParam(_message);
    dict[YSFApiKeyAccessTip] = YSFStrParam(_accessTip);
    
    dict[YSFApiKeyTransferOldSessionId] = @(_oldSessionId);
    dict[YSFApiKeySessionTransferMessage] = YSFStrParam(_transferMessage);
    
    dict[YSFApiKeySessionId] = YSFStrParam(_sessionId);
    dict[YSFApiKeyExchange] = YSFStrParam(_serviceId);
    dict[YSFApiKeyStaffType] = @(!_humanOrMachine);
    
    return dict;
}

+ (YSFStartServiceObject *)objectByDict:(NSDictionary *)dict {
    YSFStartServiceObject *instance = [[YSFStartServiceObject alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.staffId = [dict ysf_jsonString:YSFApiKeyStaffId];
    instance.iconUrl = [dict ysf_jsonString:YSFApiKeyIconUrl];
    instance.staffName = [dict ysf_jsonString:YSFApiKeyStaffName];
    instance.groupName = [dict ysf_jsonString:YSFApiKeyGroupName];
    instance.message = [dict ysf_jsonString:YSFApiKeyMessage];
    instance.accessTip = [dict ysf_jsonString:YSFApiKeyAccessTip];
    
    instance.oldSessionId = [dict ysf_jsonLongLong:YSFApiKeyTransferOldSessionId];
    instance.transferSession = instance.oldSessionId ? YES : NO;
    instance.transferMessage = [dict ysf_jsonString:YSFApiKeySessionTransferMessage];
    
    instance.sessionId = [dict ysf_jsonString:YSFApiKeySessionId];
    instance.serviceId = [dict ysf_jsonString:YSFApiKeyExchange];
    instance.humanOrMachine = ![dict ysf_jsonInteger:YSFApiKeyStaffType];
    
    return instance;
}
@end

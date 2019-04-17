//
//  YSFHistoryMsgTokenRequest.m
//  YSFSDK
//
//  Created by liaosipei on 2019/2/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFHistoryMsgTokenRequest.h"
#import "QYSDK_Private.h"

@implementation YSFHistoryMsgTokenRequest
- (NSDictionary *)toDict {
    NSDictionary *params =  @{
                              YSFApiKeyCmd : @(YSFCommandHistoryMsgTokenRequest),
                              };
    return params;
}

@end

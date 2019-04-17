//
//  YSFUserReadStatus.m
//  YSFSDK
//
//  Created by liaosipei on 2019/1/9.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFUserReadStatus.h"
#import "YSFApiDefines.h"

@implementation YSFUserReadStatus

- (NSDictionary *)toDict {
    return @{ YSFApiKeyCmd : @(YSFCommandUserReadStatusRequest),
              YSFApiKeySessionId : @(self.sessionId),
             };
}

@end

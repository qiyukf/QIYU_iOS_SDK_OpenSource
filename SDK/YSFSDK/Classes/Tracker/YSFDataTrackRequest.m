//
//  YSFDataTrackRequest.m
//  YSFSDK
//
//  Created by liaosipei on 2018/12/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFDataTrackRequest.h"
#import "QYSDK_Private.h"

@implementation YSFDataTrackRequest

- (NSDictionary *)toDict {
    return @{
             YSFApiKeyCmd : @(YSFCommandDataTrack),
             YSFApiTolerantKeyAppKey : YSFStrParam([[QYSDK sharedSDK] appKey]),
             YSFApiKeyTerminal : @(2),
             YSFApiKeyVersion : @([[[QYSDK sharedSDK].infoManager versionNumber] integerValue]),
             YSFApiKeySid : @(self.sessionId),
             YSFApiKeyType : YSFStrParam(self.type),
             YSFApiKeyProperty : self.jsonDict ? self.jsonDict : @"",
             };
}

@end

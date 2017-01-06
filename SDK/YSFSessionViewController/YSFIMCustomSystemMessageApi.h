//
//  YSFIMApi.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFApiDefines.h"

@protocol YSFIMCustomSystemMessageApiProtocol <NSObject>
- (NSDictionary *)toDict;

@optional
- (NSString *)apnContent;

@end


typedef void(^YSFIMApiBlock)(NSError *error);

@interface YSFIMCustomSystemMessageApi : NSObject

+ (void)sendMessage:(id<YSFIMCustomSystemMessageApiProtocol>)api completion:(YSFIMApiBlock)block;

+ (void)sendMessage:(id<YSFIMCustomSystemMessageApiProtocol>)api shopId:(NSString *)shopId
     completion:(YSFIMApiBlock)block;

@end

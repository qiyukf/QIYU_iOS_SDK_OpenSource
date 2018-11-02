//
//  YSFRevokeMessageResult.h
//  YSFSDK
//
//  Created by liaosipei on 2018/10/16.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFRevokeMessageResult : NSObject

@property (nonatomic, assign) NSInteger resultCode;
@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) long long timestamp;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

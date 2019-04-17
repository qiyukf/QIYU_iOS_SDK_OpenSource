//
//  YSFHistoryMessageRequest.h
//  YSFSDK
//
//  Created by liaosipei on 2019/2/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFHttpApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFHistoryMessageRequest : NSObject <YSFApiProtocol>

@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) long long beginTime;
@property (nonatomic, assign) long long endTime;
@property (nonatomic, assign) NSUInteger limit;

@end

NS_ASSUME_NONNULL_END

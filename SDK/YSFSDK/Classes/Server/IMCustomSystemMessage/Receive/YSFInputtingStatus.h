//
//  YSFInputtingStatus.h
//  YSFSDK
//
//  Created by liaosipei on 2019/4/2.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFInputtingStatus : NSObject

@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *content;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

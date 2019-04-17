//
//  YSFStaffReadStatus.h
//  YSFSDK
//
//  Created by liaosipei on 2019/1/8.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFStaffReadStatus : NSObject

@property (nonatomic, assign) long long sessionId;
@property (nonatomic, assign) long long timestamp;

+ (instancetype)dataByJson:(NSDictionary *)dict;
- (NSDictionary *)toDict;

@end

NS_ASSUME_NONNULL_END

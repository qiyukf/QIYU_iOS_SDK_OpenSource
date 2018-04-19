//
//  NIMDataTracker.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YSF_NIMDataTrackerOption : NSObject
@property (nonatomic,copy)  NSString    *name;

@property (nonatomic,copy)  NSString    *appKey;

@property (nonatomic,copy)  NSString    *version;
@end


@interface YSF_NIMDataTracker : NSObject
+ (instancetype)shared;
- (void)start:(YSF_NIMDataTrackerOption *)option;
- (void)trackEvent;
- (void)trackEvent:(NSDictionary<NSString *,NSDictionary *> *)event;

@end

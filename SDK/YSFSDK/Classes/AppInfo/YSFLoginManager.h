//
//  YSFLoginManager.h
//  YSFSDK
//
//  Created by amao on 9/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAccountInfo.h"

@protocol YSFLoginManagerDelegate <NSObject>
- (void)onLoginSuccess:(NSString *)accid;

- (void)onFatalLoginFailed:(NSError *)error;
@end

@interface YSFLoginManager : NSObject
@property (nonatomic,weak)  id<YSFLoginManagerDelegate> delegate;

- (void)tryToLogin:(YSFAccountInfo *)info;
@end

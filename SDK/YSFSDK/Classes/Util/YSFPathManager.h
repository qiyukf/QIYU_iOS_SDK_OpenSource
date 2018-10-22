//
//  YSFPathManager.h
//  YSFSDK
//
//  Created by amao on 8/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFPathManager : NSObject

- (void)setup:(NSString *)appKey;

- (NSString *)sdkRootPath;
- (NSString *)sdkGlobalPath;
- (NSString *)sdkVideoPath;

@end

//
//  YSFSessionConfigImp.h
//  YSFSDK
//
//  Created by amao on 9/6/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//
#import "YSFCellLayoutConfig.h"

@interface YSFSessionConfigImp : NSObject

+ (instancetype)sharedInstance;
- (id<YSFCellLayoutConfig>)layoutConfigWithMessage:(YSF_NIMMessage *)message;
@end

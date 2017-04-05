//
//  YSFServerSetting.h
//  YSFSDK
//
//  Created by amao on 9/1/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFServerSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic,copy)  NSString        *apiAddress;

@end

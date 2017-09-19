//
//  YSFCloseService.h
//  YSFSDK
//
//  Created by amao on 9/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

@interface YSFSessionWillCloseNotification : NSObject

@property (nonatomic,copy)    NSString *message;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

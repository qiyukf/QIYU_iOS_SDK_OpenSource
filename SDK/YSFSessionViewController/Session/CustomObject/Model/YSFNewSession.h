//
//  YSFStartServiceObject.h
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFNewSession : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;

@property (nonatomic,copy)      NSString    *userId;

@property (nonatomic,assign)    int64_t     sessionId;

@property (nonatomic,assign)    int64_t     oldSessionId;

@property (nonatomic,assign)    NSInteger   oldSessionType;

+ (YSFNewSession *)objectByDict:(NSDictionary *)dict;
@end

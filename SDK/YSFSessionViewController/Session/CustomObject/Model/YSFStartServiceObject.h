//
//  YSFStartServiceObject.h
//  YSFSDK
//
//  Created by amao on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFStartServiceObject : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;

@property (nonatomic,copy)      NSString    *staffId;

@property (nonatomic,copy)      NSString    *iconUrl;

@property (nonatomic,copy)      NSString    *staffName;

@property (nonatomic,copy)      NSString    *groupName;

@property (nonatomic,copy)      NSString    *message;

@property (nonatomic,copy)      NSString    *sessionId;

@property (nonatomic,copy)      NSString    *serviceId;

@property (nonatomic,assign)    BOOL            humanOrMachine;

+ (YSFStartServiceObject *)objectByDict:(NSDictionary *)dict;
@end

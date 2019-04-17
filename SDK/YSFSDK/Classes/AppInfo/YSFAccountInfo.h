//
//  YSFAppInfo.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFAccountInfo : NSObject

@property (nonatomic, copy) NSString *accid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) BOOL isEverLogined;
//平台电商中默认主商铺的shopId，非平台电商中的默认sessionId
@property (nonatomic, copy) NSString *bid;

+ (instancetype)infoByDict:(NSDictionary *)dict;
- (NSDictionary *)toDict;
- (BOOL)isValid;
- (BOOL)isPop;

@end

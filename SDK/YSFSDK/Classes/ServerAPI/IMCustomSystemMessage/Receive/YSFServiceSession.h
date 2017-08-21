//
//  YSFSession.h
//  YSFSDK
//
//  Created by amao on 8/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@class YSFShopInfo;
@class YSFActionInfo;

@interface YSFServiceSession : NSObject

@property (nonatomic,copy)      NSString        *serviceId;
@property (nonatomic,assign)    long long       sessionId;
@property (nonatomic,copy)      NSString        *staffId;
@property (nonatomic,assign)    long long       realStaffId;
@property (nonatomic,assign)    long long       groupId;
@property (nonatomic,copy)      NSString        *staffName;
@property (nonatomic,copy)      NSString        *iconUrl;
@property (nonatomic,strong)    NSDate          *lastServiceTime;
@property (nonatomic,assign)    NSInteger       before;
@property (nonatomic,assign)    NSInteger       code;
@property (nonatomic,assign)    BOOL            humanOrMachine;
@property (nonatomic,assign)    BOOL            operatorEable;
@property (nonatomic,copy)      NSString        *inQueeuNotify;
@property (nonatomic,copy)      NSString        *message;
@property (nonatomic,copy)      NSDictionary    *evaluation;
@property (nonatomic,copy)      NSString    *messageInvite;
@property (nonatomic,copy)      NSString    *messageThanks;
@property (nonatomic,copy)      NSArray<YSFActionInfo *>         *actionInfoArray;
@property (nonatomic,strong)    YSFShopInfo     *shopInfo;           //平台电商的商铺信息
@property (nonatomic,assign)    BOOL showNumber;


- (BOOL)canOfferService;

+ (YSFServiceSession *)dataByJson:(NSDictionary *)dict;
@end

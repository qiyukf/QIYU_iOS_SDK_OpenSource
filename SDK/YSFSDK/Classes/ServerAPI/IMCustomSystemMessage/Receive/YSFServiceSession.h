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

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, strong) NSDate *lastServiceTime;
@property (nonatomic, assign) long long sessionId;
@property (nonatomic, strong) YSFShopInfo *shopInfo;  //商铺信息
@property (nonatomic, assign) NSInteger before;

@property (nonatomic, assign) BOOL humanOrMachine;
@property (nonatomic, assign) BOOL operatorEable;
@property (nonatomic, assign) BOOL showNumber;
@property (nonatomic, assign) BOOL robotInQueue;
@property (nonatomic, assign) long long robotSessionId;

@property (nonatomic, copy) NSString *staffId;
@property (nonatomic, assign) long long realStaffId;
@property (nonatomic, assign) long long groupId;
@property (nonatomic, copy) NSString *staffName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *inQueeuNotify;
@property (nonatomic, copy) NSDictionary *evaluation;
@property (nonatomic, copy) NSString *messageInvite;
@property (nonatomic, copy) NSString *messageThanks;
@property (nonatomic, copy) NSArray<YSFActionInfo *> *actionInfoArray;

+ (YSFServiceSession *)dataByJson:(NSDictionary *)dict;
- (BOOL)canOfferService;

@end

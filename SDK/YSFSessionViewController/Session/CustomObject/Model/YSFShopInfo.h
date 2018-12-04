//
//  YSFShopInfo.h
//  YSFSDK
//
//  Created by JackyYu on 2016/12/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

@interface YSFShopSettingInfo : NSObject

@property (nonatomic, assign) BOOL sessionOpenSwitch;       //会话打开提示开关
@property (nonatomic, assign) BOOL sessionEndSwitch;        //会话结束提示开关
@property (nonatomic, assign) BOOL sessionTimeoutSwitch;    //会话超时提示开关
@property (nonatomic, assign) BOOL sessionTransferSwitch;   //会话转接提示开关
@property (nonatomic, assign) BOOL staffReadSwitch;         //消息阅读状态开关
@property (nonatomic, assign) BOOL inputSwitch;
@property (nonatomic, assign) double sendingRate;
@property (nonatomic, assign) BOOL multEvaluationEnable;    //多次评价开关
@property (nonatomic, assign) NSInteger evaluationTimeLimit;    //评价时效，单位：分钟

+ (instancetype)instanceByJson:(NSDictionary *)json;
- (NSDictionary *)toDict;

@end

@interface YSFShopInfo : NSObject

@property (nonatomic, copy) NSString *shopId;  //商户ID
@property (nonatomic, copy) NSString *name;  //商户名称
@property (nonatomic, copy) NSString *logo;  //商户Logo

@property (nonatomic, assign) BOOL hasEmail;
@property (nonatomic, assign) BOOL hasMobile;
@property (nonatomic, assign) BOOL qiyuInfoSwitch;
@property (nonatomic, strong) YSFShopSettingInfo *setting;

+ (instancetype)instanceByJson:(NSDictionary *)json;
- (NSDictionary *)toDict;

@end

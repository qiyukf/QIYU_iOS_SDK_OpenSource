//
//  YSFShopInfo.h
//  YSFSDK
//
//  Created by JackyYu on 2016/12/20.
//  Copyright © 2016年 Netease. All rights reserved.
//


@interface YSFShopInfo : NSObject

- (NSDictionary *)toDict;
+ (instancetype)instanceByJson:(NSDictionary *)json;

@property (nonatomic,copy)      NSString        *shopId;        //商户ID
@property (nonatomic,copy)      NSString        *name;          //商户名称
@property (nonatomic,copy)      NSString        *logo;          //商户Logo的URL地址

@end

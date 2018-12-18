//
//  NIMCarrierInfoProvider.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSF_NIMCarrierInfoProvider : NSObject

@property (nonatomic,copy)  NSString            *carrierName;           //运营商名字

@property (nonatomic,copy)  NSString            *mobileCountryCode;     //MCC

@property (nonatomic,copy)  NSString            *mobileNetworkCode;     //MNC

@property (nonatomic,copy)  NSString            *isoCountryCode;        //iosCC

@property (nonatomic,copy)  NSString            *radioType;             //手机制式

- (NSDictionary *)toJsonDict;
@end

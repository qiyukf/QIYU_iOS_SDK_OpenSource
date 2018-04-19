//
//  NIMDeviceInfoProvider.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSF_NIMDeviceInfoProvider : NSObject
@property (nonatomic,copy)  NSString        *brand; //品牌

@property (nonatomic,copy)  NSString        *model; //型号

@property (nonatomic,assign)  int64_t       diskSize; //磁盘空间

@property (nonatomic,assign)  int64_t       memorySize; //内存空间

@property (nonatomic,copy)  NSString        *systemName; //系统名

@property (nonatomic,copy)  NSString        *systemVersion; //系统版本

@property (nonatomic,copy)  NSString        *language; //语言

@property (nonatomic,copy)  NSString        *timeZone; //时区

- (NSDictionary *)toJsonDict;
@end

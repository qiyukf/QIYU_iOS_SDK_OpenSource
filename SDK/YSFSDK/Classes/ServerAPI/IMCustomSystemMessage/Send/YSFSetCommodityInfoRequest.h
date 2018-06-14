//
//  YSFSetCommodityInfoRequest.h
//  YSFSDK
//
//  Created by JackyYu on 16/5/26.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"

@class QYCommodityInfo;

@interface YSFSetCommodityInfoRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic, copy) NSDictionary *commodityInfo;

@end

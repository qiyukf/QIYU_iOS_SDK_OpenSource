//
//  YSFSetCommodityInfoRequest.m
//  YSFSDK
//
//  Created by JackyYu on 16/5/26.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFSetCommodityInfoRequest.h"
#import "QYCommodityInfo.h"

@implementation YSFSetCommodityInfoRequest

- (NSDictionary *)toDict
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd :   @(YSFCommandSetCommodityInfoRequest),
                                       }];
    if (_commodityInfo) {
        [params addEntriesFromDictionary:_commodityInfo];
    }
    
    return params;
}

@end

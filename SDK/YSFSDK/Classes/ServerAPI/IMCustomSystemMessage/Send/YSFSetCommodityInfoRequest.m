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
    NSNumber *showNumber = [[NSNumber alloc] initWithBool:_commodityInfo.show];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addEntriesFromDictionary:@{
                                       YSFApiKeyCmd :   @(YSFCommandSetCommodityInfoRequest),
                                       YSFApiKeyShow:   showNumber,
                                       }];
    
    if ([_commodityInfo.title length]) {
        [params setObject:_commodityInfo.title forKey:YSFApiKeyTitle];
    }
    if ([_commodityInfo.desc length]) {
        [params setObject:_commodityInfo.desc forKey:YSFApiKeyDesc];
    }
    if ([_commodityInfo.pictureUrlString length]) {
        [params setObject:_commodityInfo.pictureUrlString forKey:YSFApiKeyPicture];
    }
    if ([_commodityInfo.urlString length]) {
        [params setObject:_commodityInfo.urlString forKey:YSFApiKeyUrl];
    }
    if ([_commodityInfo.note length]) {
        [params setObject:_commodityInfo.note forKey:YSFApiKeyNote];
    }
    if ([_commodityInfo.ext length]) {
        [params setObject:_commodityInfo.ext forKey:YSFApiKeyExt];
    }

    return params;
}

@end

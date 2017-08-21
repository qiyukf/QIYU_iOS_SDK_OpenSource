//
//  QYCommodityInfo.m
//  YSFSDK
//
//  Created by JackyYu on 16/5/26.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "QYCommodityInfo.h"

@implementation QYCommodityInfo

- (BOOL)isEqual:(id)object
{
    if ([object isMemberOfClass:[QYCommodityInfo class]])
    {
        QYCommodityInfo *newCommodityInfo = object;
        if (((!_title && !newCommodityInfo.title) || [_title isEqualToString:newCommodityInfo.title])
            && ((!_desc && !newCommodityInfo.desc) || [_desc isEqualToString:newCommodityInfo.desc])
            && ((!_urlString && !newCommodityInfo.urlString) || [_urlString isEqualToString:newCommodityInfo.urlString])) {
            return YES;
        }
    }
    
    return NO;
}

@end

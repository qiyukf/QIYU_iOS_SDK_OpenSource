//
//  YSFViewHistoryAPI.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFHttpApi.h"

@interface YSFViewHistoryRequest : NSObject<YSFApiProtocol>
@property (nonatomic,copy)      NSString        *urlString;
@property (nonatomic,strong)    NSDictionary    *attributes;

@end

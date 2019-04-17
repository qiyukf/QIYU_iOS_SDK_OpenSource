//
//  YSFCreateAccountAPI.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFHttpApi.h"


@interface YSFCreateAccountRequest : NSObject<YSFApiProtocol>

@property (nonatomic, copy) NSString *foreignID;
@property (nonatomic, copy) NSString *crmInfo;
@property (nonatomic, copy) NSString *authToken;

@end

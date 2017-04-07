//
//  YSFCommandWaitingStatus.h
//  YSFSDK
//
//  Created by panqinke on 10/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"

@interface YSFQueryWaitingStatusRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>


@end


@interface YSFQueryWaitingStatusResponse : NSObject

@property (nonatomic,assign)    NSInteger       waitingNumber;
@property (nonatomic,assign)    NSInteger       code;
@property (nonatomic,copy)      NSString        *message;
@property (nonatomic,copy)      NSString        *shopId;
@property (nonatomic,assign)    BOOL       showNumber;
@property (nonatomic,copy)      NSString        *inQueeuNotify;

+ (YSFQueryWaitingStatusResponse *)dataByJson:(NSDictionary *)dict;
@end

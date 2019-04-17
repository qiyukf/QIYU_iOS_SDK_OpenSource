//
//  YSFUserReadStatus.h
//  YSFSDK
//
//  Created by liaosipei on 2019/1/9.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFIMCustomSystemMessageApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFUserReadStatus : NSObject <YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic, assign) long long sessionId;

@end

NS_ASSUME_NONNULL_END

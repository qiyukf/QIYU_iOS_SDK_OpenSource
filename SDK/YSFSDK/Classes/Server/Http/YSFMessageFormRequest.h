//
//  YSFMessageFormRequest.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFHttpApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFMessageFormRequest : NSObject <YSFApiProtocol>

@property (nonatomic, copy) NSString *shopId;

@end

NS_ASSUME_NONNULL_END

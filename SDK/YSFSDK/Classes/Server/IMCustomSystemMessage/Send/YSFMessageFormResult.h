//
//  YSFMessageFormResult.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFIMCustomSystemMessageApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFMessageFormResult : NSObject <YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic, copy) NSString *shopId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *customFields;

@end

NS_ASSUME_NONNULL_END

//
//  YSFMessageFormResponse.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFMessageFormResponse : NSObject

@property (nonatomic, assign) NSInteger auditResult;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

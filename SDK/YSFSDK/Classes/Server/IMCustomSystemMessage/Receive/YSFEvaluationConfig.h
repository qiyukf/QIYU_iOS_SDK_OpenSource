//
//  YSFEvaluationConfig.h
//  YSFSDK
//
//  Created by liaosipei on 2019/1/11.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFEvaluationConfig : NSObject

+ (instancetype)dataByJson:(NSDictionary *)dict;
- (NSDictionary *)toDict;

@end

NS_ASSUME_NONNULL_END

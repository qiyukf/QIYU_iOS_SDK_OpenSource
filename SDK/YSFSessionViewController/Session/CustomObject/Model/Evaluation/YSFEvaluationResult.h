//
//  YSFEvaluationResult.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/10/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFEvaluationResult : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *desc;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

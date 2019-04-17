//
//  YSFMessageFormResultObject.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFCustomAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFMessageFormResultObject : NSObject <YSFCustomAttachment>

@property (nonatomic, assign) long long command;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *fields;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

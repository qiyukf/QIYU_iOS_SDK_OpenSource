//
//  YSFCustomMessageAttachment.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/23.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFCustomAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@class QYCustomMessage;
@interface YSFCustomMessageAttachment : NSObject <YSFCustomAttachment>

@property (nonatomic, strong) QYCustomMessage *message;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

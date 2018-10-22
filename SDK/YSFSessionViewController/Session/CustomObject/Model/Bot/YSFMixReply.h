//
//  YSFMixReply.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/8/24.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFCustomAttachment.h"
#import "YSFAction.h"

@interface YSFMixReply : NSObject <YSFCustomAttachment>

@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSArray<YSFAction *> *actionList;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

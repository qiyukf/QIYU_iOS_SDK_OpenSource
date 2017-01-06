//
//  YSFFinishSessionApi.h
//  QYKF
//
//  Created by 金华 on 16/3/23.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFIMCustomSystemMessageApi.h"

@interface YSFWeChatMessage : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,copy)    NSString *from;
@property (nonatomic,copy)    NSString *to;
@property (nonatomic,copy)    NSString *type;
@property (nonatomic,copy)    NSString *body;

@end
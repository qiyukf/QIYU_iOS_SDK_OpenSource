//
//  YSFInputMoreContainerView.h
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionConfig.h"
#import "YSFInputProtocol.h"


@interface YSFInputMoreContainerView : UIView

@property (nonatomic,weak)  id<YSFSessionConfig> config;
@property (nonatomic,weak)  id<YSFInputActionDelegate> actionDelegate;

@end

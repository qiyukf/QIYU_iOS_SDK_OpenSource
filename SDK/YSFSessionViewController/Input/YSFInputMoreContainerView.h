//
//  YSFInputMoreContainerView.h
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFInputProtocol.h"


@interface YSFInputMoreContainerView : UIView

@property (nonatomic,weak)  id<YSFInputActionDelegate> actionDelegate;
- (void)genMediaButtons;

@end

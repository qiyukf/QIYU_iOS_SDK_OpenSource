//
//  YSFVideoPlayerViewController.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFPresentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class YSF_NIMMessage;
@interface YSFVideoPlayerViewController : UIViewController

@property (nonatomic, strong) YSF_NIMMessage *message;
@property (nonatomic, assign) BOOL soundOff;

@end

NS_ASSUME_NONNULL_END

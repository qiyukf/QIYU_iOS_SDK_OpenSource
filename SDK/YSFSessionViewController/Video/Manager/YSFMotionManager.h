//
//  YSFMotionManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface YSFMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;
@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end

NS_ASSUME_NONNULL_END

//
//  YSFMotionManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface YSFMotionManager ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation YSFMotionManager

- (void)dealloc {
//    NSLog(@"YSFMotionManager dealloc");
    [_motionManager stopDeviceMotionUpdates];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/15.0;
        if (!_motionManager.deviceMotionAvailable) {
            _motionManager = nil;
            return self;
        }
        __weak typeof(self) weakSelf = self;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
    return self;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _videoOrientation  = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            _deviceOrientation = UIDeviceOrientationPortrait;
            _videoOrientation  = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0) {
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            _videoOrientation  = AVCaptureVideoOrientationLandscapeRight;
        } else {
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            _videoOrientation  = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}

@end

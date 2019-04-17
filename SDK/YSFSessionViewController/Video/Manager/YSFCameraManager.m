//
//  YSFCameraManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFCameraManager.h"

@implementation YSFCameraManager
- (void)dealloc {
    YSFLogApp(@"");
}

- (AVCaptureDeviceInput *)flipCamera:(AVCaptureSession *)session
                            oldInput:(AVCaptureDeviceInput *)oldInput
                            newInput:(AVCaptureDeviceInput *)newInput {
    [session beginConfiguration];
    [session removeInput:oldInput];
    if ([session canAddInput:newInput]) {
        [session addInput:newInput];
        [session commitConfiguration];
        return newInput;
    } else {
        YSFLogApp(@"FlipCamera ERROR: can not add new input");
        [session addInput:oldInput];
        [session commitConfiguration];
        return oldInput;
    }
}

@end

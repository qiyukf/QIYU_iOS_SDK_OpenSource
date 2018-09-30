//
//  YSFCameraManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface YSFCameraManager : NSObject

/**
 * 翻转摄像头
 */
- (AVCaptureDeviceInput *)flipCamera:(AVCaptureSession *)session
                            oldInput:(AVCaptureDeviceInput *)oldInput
                            newInput:(AVCaptureDeviceInput *)newInput;

@end

NS_ASSUME_NONNULL_END

//
//  YSFVideoPreviewView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoPreviewView.h"

@implementation YSFVideoPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return self;
}

- (void)setCaptureSession:(AVCaptureSession *)captureSession {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:captureSession];
}

- (AVCaptureSession *)captureSession {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}


@end

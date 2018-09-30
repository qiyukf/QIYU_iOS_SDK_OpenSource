//
//  YSFVideoPreviewView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface YSFVideoPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

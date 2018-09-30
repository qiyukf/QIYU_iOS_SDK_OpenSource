//
//  YSFCameraView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFVideoPreviewView.h"

typedef NS_ENUM(NSInteger, YSFCameraViewStatus) {
    YSFCameraViewStatusInit = 0,    //初始状态：显示录音按钮(start)、关闭按钮、翻转按钮、30秒
    YSFCameraViewStatusRecording,   //录制状态：显示录音按钮(stop)、进度条、秒数
    YSFCameraViewStatusDone,        //完成状态：显示返回按钮、发送按钮、进度条、秒数
};

@protocol YSFCameraViewDelegate <NSObject>

- (void)startRecordVideo;
- (void)stopRecordVideoWithTime:(double)videoTime;
- (void)closeCameraView;
- (void)flipCamera;
- (void)backToInitCameraView;
- (void)sendVideoData;

@end

@interface YSFCameraView : UIView

@property (nonatomic, weak) id<YSFCameraViewDelegate> delegate;
@property (nonatomic, strong) YSFVideoPreviewView *videoPreview;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign, readonly) YSFCameraViewStatus status;

- (void)updateStatus:(YSFCameraViewStatus)status animated:(BOOL)animate;

@end

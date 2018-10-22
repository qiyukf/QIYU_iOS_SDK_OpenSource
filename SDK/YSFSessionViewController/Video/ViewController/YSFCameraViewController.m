//
//  YSFCameraViewController.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFCameraViewController.h"
#import "YSFCameraView.h"
#import "YSFCameraManager.h"
#import "YSFVideoDataManager.h"
#import "YSFMotionManager.h"
@import AVFoundation;

@interface YSFCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, YSFCameraViewDelegate> {
    //会话
    AVCaptureSession *_session;
    //输入
    AVCaptureDeviceInput *_deviceInput;
    //输出
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    AVCaptureVideoDataOutput *_videoOutput;
    
    NSURL *_videoDataURL;
}

@property (nonatomic, strong) YSFCameraView *cameraView;

@property (nonatomic, strong) AVCaptureDevice *activeCamera;    //当前输入设备
@property (nonatomic, strong) AVCaptureDevice *inactiveCamera;  //不活跃的设备(前摄像头/后摄像头)

@property (nonatomic, strong) YSFCameraManager *cameraManager;
@property (nonatomic, strong) YSFMotionManager *motionManager;

@end

@implementation YSFCameraViewController

- (void)dealloc {
//    NSLog(@"YSFCameraViewController dealloc");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cameraManager = [[YSFCameraManager alloc] init];
        _motionManager = [[YSFMotionManager alloc] init];
    }
    return self;
}

#pragma mark - view load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.cameraView = [[YSFCameraView alloc] initWithFrame:self.view.frame];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    NSError *error = nil;
    [self setupSession:&error];
    if (!error) {
        [self.cameraView.videoPreview setCaptureSession:_session];
        [self startCaptureSession];
    } else {
        [self showToast:@"启动相机失败"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.cameraView updateStatus:YSFCameraViewStatusInit animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        [self.cameraView setInsets:safeAreaInsets];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - capture init
- (void)setupSession:(NSError **)error {
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPreset640x480;
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

- (void)setupSessionInputs:(NSError **)error {
    //视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    //音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audieInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audieInput) {
        if ([_session canAddInput:audieInput]) {
            [_session addInput:audieInput];
        }
    }
}

- (void)setupSessionOutputs:(NSError **)error {
    dispatch_queue_t captureQueue = dispatch_queue_create("com.netease.captureQueue", DISPATCH_QUEUE_SERIAL);
    //视频输出
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    NSDictionary *setting = @{
                              (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                              };
    videoOutput.videoSettings = setting;
    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOutput]) {
        [_session addOutput:videoOutput];
    }
    _videoOutput = videoOutput;
    _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //音频输出
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:audioOutput]) {
        [_session addOutput:audioOutput];
    }
    _audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

#pragma mark - device
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (position == device.position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 1) {
        if (AVCaptureDevicePositionBack == self.activeCamera.position) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else if (AVCaptureDevicePositionFront == self.activeCamera.position) {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

#pragma mark - session control
- (void)startCaptureSession {
    if (_session.isRunning) {
//        NSLog(@"startCaptureSession: session is running");
    } else {
        [_session startRunning];
    }
}

- (void)stopCaptureSession {
    if (_session.isRunning) {
        [_session stopRunning];
    } else {
//        NSLog(@"stopCaptureSession: session is not running");
    }
}

#pragma mark - OutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (YSFCameraViewStatusRecording == self.cameraView.status) {
        [[YSFVideoDataManager sharedManager] writeData:connection
                                       videoConnection:_videoConnection
                                       audioConnection:_audioConnection
                                                buffer:sampleBuffer];
    }
}

#pragma mark - YSFCameraViewDelegate
- (void)startRecordVideo {
    [self startCaptureSession];
    [self.cameraView updateStatus:YSFCameraViewStatusRecording animated:YES];
    
    NSString *fileName = [NSString stringWithFormat:@"video_%@.mp4", [self getMilliSecondTimeStamp]];
    [YSFVideoDataManager sharedManager].dataPath = [NSString stringWithFormat:@"%@/%@", _videoDataPath, fileName];
    
    [YSFVideoDataManager sharedManager].currentDevice = self.activeCamera;
    [YSFVideoDataManager sharedManager].currentOrientation = [self currentVideoOrientation];
    __weak typeof(self) weakSelf = self;
    [[YSFVideoDataManager sharedManager] startWriteDataHandler:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showToast:error.localizedDescription];
        }
    }];
}

- (void)stopRecordVideoWithTime:(double)videoTime {
    if (videoTime < 1) {
        [self showToast:@"视频至少录制1秒"];
        [self.cameraView updateStatus:YSFCameraViewStatusInit animated:YES];
    } else {
        [self stopCaptureSession];
        [self.cameraView updateStatus:YSFCameraViewStatusDone animated:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    [[YSFVideoDataManager sharedManager] stopWriteDataHandler:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showToast:error.localizedDescription];
        } else {
            //视频存储在url下
            if (videoTime < 1) {
                [[YSFVideoDataManager sharedManager] deleteVideoDataCompletion:nil];
            }
            strongSelf->_videoDataURL = url;
        }
    }];
}

- (void)closeCameraView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)flipCamera {
    NSError *error = nil;
    AVCaptureDevice *newDevice = self.inactiveCamera;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:&error];
    if (newInput) {
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.videoPreview.layer addAnimation:animation forKey:@"flip"];
        
        _deviceInput = [self.cameraManager flipCamera:_session oldInput:_deviceInput newInput:newInput];
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    }
    if (error) {
        [self showToast:@"转换摄像头失败"];
    }
}

- (void)backToInitCameraView {
    [self startCaptureSession];
    [self.cameraView updateStatus:YSFCameraViewStatusInit animated:YES];
    [[YSFVideoDataManager sharedManager] deleteVideoDataCompletion:nil];
}

- (void)sendVideoData {
    if (!_videoDataURL || !_videoDataURL.path.length) {
        if ([YSFVideoDataManager sharedManager].dataPath.length) {
            _videoDataURL = [NSURL fileURLWithPath:[YSFVideoDataManager sharedManager].dataPath];
        }
    }
    if ([self.delegate respondsToSelector:@selector(sendVideoMessage:)]) {
        [self.delegate sendVideoMessage:_videoDataURL];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - toast
- (void)showToast:(NSString *)string {
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    if (topWindow) {
        [topWindow ysf_makeToast:string duration:2.0f position:YSFToastPositionCenter];
    }
}

- (NSString *)getMilliSecondTimeStamp {
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)(floor([[NSDate date] timeIntervalSince1970] * 1000))];
    return timeStamp;
}

@end



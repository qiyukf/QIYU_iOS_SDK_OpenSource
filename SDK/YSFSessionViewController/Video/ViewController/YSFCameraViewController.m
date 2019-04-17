//
//  YSFCameraViewController.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFCameraViewController.h"
#import "YSFAlertController.h"
#import "YSFCameraView.h"
#import "YSFAssetWriteManager.h"
#import "YSFCameraManager.h"
#import "YSFMotionManager.h"
#import "YSFVideoDataManager.h"
@import AVFoundation;

@interface YSFCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, YSFCameraViewDelegate> {
    //会话
    AVCaptureSession *_session;
    //输入
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
    //输出
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    AVCaptureVideoDataOutput *_videoOutput;
    
    NSURL *_videoDataURL;
}

@property (nonatomic, strong) YSFCameraView *cameraView;

@property (nonatomic, strong) AVCaptureDevice *activeCamera;    //当前输入设备
@property (nonatomic, strong) AVCaptureDevice *inactiveCamera;  //不活跃的设备(前摄像头/后摄像头)

@property (nonatomic, strong) YSFAssetWriteManager *writeManager;
@property (nonatomic, strong) YSFCameraManager *cameraManager;
@property (nonatomic, strong) YSFMotionManager *motionManager;

@end

@implementation YSFCameraViewController

- (void)dealloc {
    YSFLogApp(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    _writeManager = nil;
    _cameraManager = nil;
    _motionManager = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _writeManager = [[YSFAssetWriteManager alloc] init];
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
    
    if ([self setupSession]) {
        [self.cameraView.videoPreview setCaptureSession:_session];
        [self startCaptureSession];
    } else {
        [self showAlert:@"相机启动失败，请重新尝试"];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(WillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cameraView updateStatus:YSFCameraViewStatusInit animated:NO];
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
- (BOOL)setupSession {
    _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    } else if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _session.sessionPreset = AVCaptureSessionPreset640x480;
    } else {
        YSFLogApp(@"AVCaptureSession ERROR: can not set session preset");
        return NO;
    }
    if (![self setupSessionInputs]) {
        return NO;
    }
    if (![self setupSessionOutputs]) {
        return NO;
    }
    return YES;
}

- (BOOL)setupSessionInputs {
    //视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *videoErr = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&videoErr];
    if (!videoErr && videoInput && [_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    } else {
        YSFLogApp([NSString stringWithFormat:@"AVCaptureDeviceInput ERROR: can not add video input, info: %@", YSFStrParam(videoErr.userInfo)]);
        return NO;
    }
    _videoInput = videoInput;
    //音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *audioErr = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&audioErr];
    if (!audioErr && audioInput && [_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    } else {
        YSFLogApp([NSString stringWithFormat:@"AVCaptureDeviceInput ERROR: can not add audio input, info: %@", YSFStrParam(audioErr.userInfo)]);
        return NO;
    }
    _audioInput = audioInput;
    return YES;
}

- (BOOL)setupSessionOutputs {
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
    } else {
        YSFLogApp(@"AVCaptureVideoDataOutput ERROR: can not add video output");
        return NO;
    }
    _videoOutput = videoOutput;
    _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //音频输出
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:audioOutput]) {
        [_session addOutput:audioOutput];
    } else {
        YSFLogApp(@"AVCaptureAudioDataOutput ERROR: can not add audio output");
        return NO;
    }
    _audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    return YES;
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
    return _videoInput.device;
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
        YSFLogApp(@"Warning: session is already running");
    } else {
        [_session startRunning];
    }
}

- (void)stopCaptureSession {
    if (_session.isRunning) {
        [_session stopRunning];
    } else {
        YSFLogApp(@"Warning: session is not running");
    }
}

#pragma mark - OutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (YSFCameraViewStatusRecording == self.cameraView.status) {
        [self.writeManager writeData:connection videoConnection:_videoConnection audioConnection:_audioConnection buffer:sampleBuffer];
    }
}

#pragma mark - YSFCameraViewDelegate
- (void)startRecordVideo {
    [self startCaptureSession];
    [self.cameraView updateStatus:YSFCameraViewStatusRecording animated:YES];
    
    NSString *fileName = [NSString stringWithFormat:@"video_%@.mp4", [self getMilliSecondTimeStamp]];
    self.writeManager.dataPath = [NSString stringWithFormat:@"%@/%@", _videoDataPath, fileName];
    self.writeManager.outputSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.writeManager.currentDevice = self.activeCamera;
    self.writeManager.currentOrientation = [self currentVideoOrientation];
    
    __weak typeof(self) weakSelf = self;
    [self.writeManager startWriteDataHandler:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!success) {
            YSFLogApp([NSString stringWithFormat:@"AVAssetWriter ERROR, info: %@", YSFStrParam(error.userInfo)]);
            [strongSelf showAlert:@"视频录制失败，请重新尝试"];
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
    [self.writeManager stopWriteDataHandler:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            YSFLogApp([NSString stringWithFormat:@"AVAssetWriter ERROR, info: %@", YSFStrParam(error.userInfo)]);
            [strongSelf showAlert:@"视频录制失败，请重新尝试"];
        } else {
            //视频存储在url下
            if (videoTime < 1) {
                [[YSFVideoDataManager sharedManager] deleteVideoDataPath:url.path completion:nil];
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
    if (newInput && !error) {
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.videoPreview.layer addAnimation:animation forKey:@"flip"];
        
        _videoInput = [self.cameraManager flipCamera:_session oldInput:_videoInput newInput:newInput];
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    } else {
        YSFLogApp([NSString stringWithFormat:@"FlipCamera ERROR: no new input, info: %@", YSFStrParam(error.userInfo)]);
        [self showToast:@"摄像头切换失败"];
    }
}

- (void)backToInitCameraView {
    [self startCaptureSession];
    [self.cameraView updateStatus:YSFCameraViewStatusInit animated:YES];
    [[YSFVideoDataManager sharedManager] deleteVideoDataPath:self.writeManager.dataPath completion:nil];
}

- (void)sendVideoData {
    if (!_videoDataURL || !_videoDataURL.path.length) {
        if (self.writeManager.dataPath.length) {
            _videoDataURL = [NSURL fileURLWithPath:self.writeManager.dataPath];
        } else {
            [self showToast:@"发生未知错误，视频数据为空"];
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(sendVideoMessage:)]) {
        [self.delegate sendVideoMessage:_videoDataURL];
    }
    [self closeCameraView];
}

#pragma mark - notification
- (void)DidEnterBackgroundNotification:(NSNotification *)notification {
    
}

- (void)WillEnterForegroundNotification:(NSNotification *)notification {
    
}

#pragma mark - toast
- (void)showToast:(NSString *)string {
    UIWindow *topWindow = [self getLastWindow];
    if (topWindow) {
        [topWindow ysf_makeToast:string duration:2.0f position:YSFToastPositionCenter];
    }
}

- (UIWindow *)getLastWindow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]]
            && CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)
            && !window.hidden) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)showAlert:(NSString *)string {
    YSFAlertController *alert = [YSFAlertController alertWithTitle:string message:nil];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction *action) {
        [weakSelf closeCameraView];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert showWithSender:nil controller:weakSelf animated:YES completion:nil];
    });
}

- (NSString *)getMilliSecondTimeStamp {
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)(floor([[NSDate date] timeIntervalSince1970] * 1000))];
    return timeStamp;
}

@end



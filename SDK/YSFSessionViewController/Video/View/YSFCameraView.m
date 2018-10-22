//
//  YSFCameraView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFCameraView.h"
#import "YSFVideoProgressView.h"
#import "YSFTimer.h"

static CGFloat kCameraViewSpace = 15.0f;
static CGFloat kCameraViewCloseSize = 20.0f;
static CGFloat kCameraViewFlipWidth = 26.0f;
static CGFloat kCameraViewFlipHeight = 22.0f;
static CGFloat kCameraViewRecordSize = 72.0f;
static CGFloat kCameraViewRecordSpace = 46.0f;
static CGFloat kCameraViewTimeWidth = 30.0f;
static CGFloat kCameraViewTimeHeight = 18.0f;
static CGFloat kCameraViewProgressLeftSpace = 20.0f;
static CGFloat kCameraViewProgressRightSpace = 9.0f;
static CGFloat kCameraViewProgressBottomSpace = 21.0f;
static CGFloat kCameraViewProgressHeight = 6.0f;
static CGFloat kCameraViewButtonGap = 68.0f;
static CGFloat kCameraViewProgressButtonGap = 21.0f;

static CGFloat kRecordMaxTime = 30;
static CGFloat kRecordDegreeTime = 0.02;

@interface YSFCameraView () <CAAnimationDelegate> {
    YSFTimer *_timer;
    NSInteger _execution;
    BOOL _isFlipCamera;
}

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *closeLargeButton;
@property (nonatomic, strong) UIButton *flipCameraButton;
@property (nonatomic, strong) UIButton *flipCameraLargeButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) YSFVideoProgressView *progressView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation YSFCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isFlipCamera = NO;
    }
    return self;
}

#pragma mark - setter
- (YSFVideoPreviewView *)videoPreview {
    if (!_videoPreview) {
        _videoPreview = [[YSFVideoPreviewView alloc] initWithFrame:CGRectZero];
        [self addSubview:_videoPreview];
    }
    return _videoPreview;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setImage:[UIImage ysf_imageInKit:@"video_close.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

- (UIButton *)closeLargeButton {
    if (!_closeLargeButton) {
        _closeLargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeLargeButton.backgroundColor = [UIColor clearColor];
        [_closeLargeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeLargeButton];
    }
    return _closeLargeButton;
}

- (UIButton *)flipCameraButton {
    if (!_flipCameraButton) {
        _flipCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flipCameraButton.backgroundColor = [UIColor clearColor];
        [_flipCameraButton setImage:[UIImage ysf_imageInKit:@"video_camera_flip.png"] forState:UIControlStateNormal];
        [_flipCameraButton addTarget:self action:@selector(clickFlipCameraButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_flipCameraButton];
    }
    return _flipCameraButton;
}

- (UIButton *)flipCameraLargeButton {
    if (!_flipCameraLargeButton) {
        _flipCameraLargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flipCameraLargeButton.backgroundColor = [UIColor clearColor];
        [_flipCameraLargeButton addTarget:self action:@selector(clickFlipCameraButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_flipCameraLargeButton];
    }
    return _flipCameraLargeButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.backgroundColor = [UIColor clearColor];
        UIImage *startImg = [UIImage ysf_imageInKit:@"video_record_start.png"];
        UIImage *stopImg = [UIImage ysf_imageInKit:@"video_record_stop.png"];
        [_recordButton setImage:startImg forState:UIControlStateNormal];
        [_recordButton setImage:stopImg forState:UIControlStateSelected];
        [_recordButton addTarget:self action:@selector(clickRecordButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_recordButton];
    }
    return _recordButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:_timeLabel];
        [self updateTimeLabel:kRecordMaxTime];
    }
    return _timeLabel;
}

- (YSFVideoProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[YSFVideoProgressView alloc] init];
        _progressView.progressValue = 0.0;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        [_backButton setImage:[UIImage ysf_imageInKit:@"video_back.png"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
    }
    return _backButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = [UIColor clearColor];
        [_sendButton setImage:[UIImage ysf_imageInKit:@"video_send.png"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
    }
    return _sendButton;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoPreview.frame = self.bounds;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.closeButton.frame = CGRectMake(kCameraViewSpace, kCameraViewSpace + statusBarHeight, kCameraViewCloseSize, kCameraViewCloseSize);
    self.closeLargeButton.frame = CGRectMake(0, statusBarHeight, kCameraViewCloseSize + 2 * kCameraViewSpace, kCameraViewCloseSize + 2 * kCameraViewSpace);
    self.flipCameraButton.frame = CGRectMake(CGRectGetWidth(self.frame) - kCameraViewSpace - kCameraViewFlipWidth,
                                             kCameraViewSpace + statusBarHeight,
                                             kCameraViewFlipWidth,
                                             kCameraViewFlipHeight);
    self.flipCameraLargeButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 2 * kCameraViewSpace - kCameraViewFlipWidth,
                                                  statusBarHeight,
                                                  kCameraViewFlipWidth + 2 * kCameraViewSpace,
                                                  kCameraViewFlipHeight + 2 * kCameraViewSpace);
    self.recordButton.frame = CGRectMake(roundf((CGRectGetWidth(self.frame) - kCameraViewRecordSize) / 2),
                                         CGRectGetHeight(self.frame) - _insets.bottom - kCameraViewRecordSpace - kCameraViewRecordSize,
                                         kCameraViewRecordSize,
                                         kCameraViewRecordSize);
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - kCameraViewSpace - kCameraViewTimeWidth,
                                      CGRectGetHeight(self.frame) - _insets.bottom - kCameraViewSpace - kCameraViewTimeHeight,
                                      kCameraViewTimeWidth,
                                      kCameraViewTimeHeight);
    self.progressView.frame = CGRectMake(kCameraViewProgressLeftSpace,
                                         CGRectGetHeight(self.frame) - _insets.bottom - kCameraViewProgressBottomSpace - kCameraViewProgressHeight,
                                         CGRectGetMinX(self.timeLabel.frame) - kCameraViewProgressRightSpace - kCameraViewProgressLeftSpace,
                                         kCameraViewProgressHeight);
    CGSize imgSize = self.backButton.imageView.image.size;
    self.backButton.frame = CGRectMake(roundf((CGRectGetWidth(self.frame) - 2 * imgSize.width - kCameraViewButtonGap) / 2),
                                       CGRectGetMinY(self.progressView.frame) - kCameraViewProgressButtonGap - imgSize.height,
                                       imgSize.width,
                                       imgSize.height);
    self.sendButton.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame) + kCameraViewButtonGap,
                                       CGRectGetMinY(self.backButton.frame),
                                       imgSize.width,
                                       imgSize.height);
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    if (insets.bottom > 0) {
        [self setNeedsLayout];
    }
}

- (void)updateStatus:(YSFCameraViewStatus)status animated:(BOOL)animate {
    _status = status;
    [self hideAllView];
    if (YSFCameraViewStatusInit == status) {
        if (animate) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self showInitCameraView];
                             }];
        } else {
            [self showInitCameraView];
        }
    } else if (YSFCameraViewStatusRecording == status) {
        if (animate) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self showRecordingCameraView];
                             }];
        } else {
            [self showRecordingCameraView];
        }
    } else if (YSFCameraViewStatusDone == status) {
        if (animate) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self showDoneCameraView];
                             }];
        } else {
            [self showDoneCameraView];
        }
    }
}

- (void)hideAllView {
    self.recordButton.hidden = YES;
    self.recordButton.selected = YES;
    
    self.closeButton.hidden = YES;
    self.closeLargeButton.hidden = YES;
    self.flipCameraButton.hidden = YES;
    self.flipCameraLargeButton.hidden = YES;
    self.timeLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.backButton.hidden = YES;
    self.sendButton.hidden = YES;
}

- (void)showInitCameraView {
    self.recordButton.hidden = NO;
    self.recordButton.selected = NO;
    
    self.closeButton.hidden = NO;
    self.closeLargeButton.hidden = NO;
    self.flipCameraButton.hidden = NO;
    self.flipCameraLargeButton.hidden = NO;
    self.timeLabel.hidden = NO;
    [self updateTimeLabel:kRecordMaxTime];
    self.progressView.hidden = YES;
    self.progressView.progressValue = 0.0;
    self.backButton.hidden = YES;
    self.sendButton.hidden = YES;
}

- (void)showRecordingCameraView {
    self.recordButton.hidden = NO;
    self.recordButton.selected = YES;
    
    self.closeButton.hidden = YES;
    self.closeLargeButton.hidden = YES;
    self.flipCameraButton.hidden = YES;
    self.flipCameraLargeButton.hidden = YES;
    self.timeLabel.hidden = NO;
    self.progressView.hidden = NO;
    self.progressView.progressValue = 0.0;
    self.backButton.hidden = YES;
    self.sendButton.hidden = YES;
}

- (void)showDoneCameraView {
    self.recordButton.hidden = YES;
    self.recordButton.selected = NO;
    
    self.closeButton.hidden = YES;
    self.closeLargeButton.hidden = YES;
    self.flipCameraButton.hidden = YES;
    self.flipCameraLargeButton.hidden = YES;
    self.timeLabel.hidden = NO;
    self.progressView.hidden = NO;
    self.backButton.hidden = NO;
    self.sendButton.hidden = NO;
}

- (void)updateTimeLabel:(NSInteger)time {
    self.timeLabel.text = [NSString stringWithFormat:@"%ld秒", (long)time];
}

#pragma mark - action
- (void)clickCloseButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeCameraView)]) {
        [self.delegate closeCameraView];
    }
}

- (void)clickFlipCameraButton:(id)sender {
    if (_isFlipCamera) {
        return;
    }
    CATransition *animation = [CATransition animation];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromLeft;
    animation.duration = 0.5;
    animation.delegate = self;
    [_flipCameraButton.layer addAnimation:animation forKey:@"flip"];
    
    if ([self.delegate respondsToSelector:@selector(flipCamera)]) {
        [self.delegate flipCamera];
    }
}

- (void)clickRecordButton:(id)sender {
    if (_isFlipCamera) {
        return;
    }
    _recordButton.selected = !_recordButton.selected;
    if (_recordButton.selected) {
        [self startRecord];
    } else {
        [self stopRecord];
    }
}

- (void)clickBackButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(backToInitCameraView)]) {
        [self.delegate backToInitCameraView];
    }
}

- (void)clickSendButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sendVideoData)]) {
        [self.delegate sendVideoData];
    }
}

- (void)startRecord {
    if ([self.delegate respondsToSelector:@selector(startRecordVideo)]) {
        [self.delegate startRecordVideo];
    }
    [self startTimerWithTimeout:kRecordMaxTime degree:kRecordDegreeTime];
}

- (void)stopRecord {
    double time = _execution * kRecordDegreeTime;
    
    if ([self.delegate respondsToSelector:@selector(stopRecordVideoWithTime:)]) {
        [self.delegate stopRecordVideoWithTime:time];
    }
    [self stopTimer];
}

#pragma mark - timer
- (void)startTimerWithTimeout:(CGFloat)timeout degree:(CGFloat)degree {
    if (!_timer) {
        _timer = [[YSFTimer alloc] init];
    }
    self.progressView.progressValue = 0.0;
    [self updateTimeLabel:0];
    
    NSInteger totalTimes = timeout / degree; //总共需要执行150次
    NSInteger secondTimes = 1 / degree; //每5次是1秒
    _execution = 0;
    __weak typeof(self) weakSelf = self;
    [_timer start:dispatch_get_main_queue() interval:degree repeats:YES block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_execution++;
        double value = ((double)strongSelf->_execution / totalTimes);
        strongSelf.progressView.progressValue = value;
        if ((strongSelf->_execution % secondTimes) == 0) {
            NSInteger time = (strongSelf->_execution / secondTimes);
            [strongSelf updateTimeLabel:time];
        }
        if (strongSelf->_execution == totalTimes) {
            [strongSelf stopRecord];
        }
    }];
}

- (void)stopTimer {
    if (_timer && !_timer.isStopped) {
        [_timer stop];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    _isFlipCamera = YES;
    self.flipCameraButton.userInteractionEnabled = NO;
    self.recordButton.userInteractionEnabled = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _isFlipCamera = NO;
    self.flipCameraButton.userInteractionEnabled = YES;
    self.recordButton.userInteractionEnabled = YES;
}

@end

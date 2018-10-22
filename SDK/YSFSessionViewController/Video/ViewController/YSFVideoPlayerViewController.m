//
//  YSFVideoPlayerViewController.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoPlayerViewController.h"
#import "YSFVideoPlayer.h"
#import "YSFVideoHandleBar.h"
#import "YSFTimer.h"
#import "YSFAlertController.h"
#import "YSFVideoDataManager.h"

typedef NS_ENUM(NSInteger, YSFVideoPlayerStatus) {
    YSFVideoPlayerStatusHidden = 0,    //初始状态：全屏播放，没有任何按钮
    YSFVideoPlayerStatusHandle,      //操作状态：出现关闭按钮、操作条
    YSFVideoPlayerStatusDone,        //完成状态：
};

static CGFloat kVideoPlayerViewSpace = 15.0f;
static CGFloat kVideoPlayerViewCloseSize = 20.0f;
static CGFloat kVideoPlayerViewButtonSize = 72.0f;
static CGFloat kVideoPlayerViewBarBottom = 15.0f;
static CGFloat kVideoPlayerViewBarHeight = 18.0f;

@interface YSFVideoPlayerViewController () <YSFVideoHandleBarDelegate> {
    YSFTimer *_timer;
}

@property (nonatomic, strong) YSFVideoPlayer *videoPlayer;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *closeLargeButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) YSFVideoHandleBar *handleBar;

@property (nonatomic, assign) YSFVideoPlayerStatus status;

@end

@implementation YSFVideoPlayerViewController

- (void)dealloc {
//    NSLog(@"YSFVideoPlayerViewController dealloc");
}

#pragma mark - view load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.view addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(longPressScreen:)];
    [self.view addGestureRecognizer:longPressGesture];
    
    self.status = YSFVideoPlayerStatusHidden;
    [self.handleBar updatePlayButton:YES];
    __weak typeof(self) weakSelf = self;
    [self.videoPlayer startWithMessage:self.message
                              soundOff:self.soundOff
                           statusBlock:^(NSTimeInterval curTime, NSTimeInterval totalTime) {
                               [weakSelf updateHandleBarWithCurTime:curTime totalTime:totalTime];
                           }];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (@available(iOS 11, *)) {
        UIEdgeInsets inset = self.view.safeAreaInsets;
        if (inset.bottom > 0) {
            YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)self.message.messageObject;
            CGSize videoSize = videoObject.coverSize;
            CGFloat height = (videoSize.height / videoSize.width) * CGRectGetWidth(self.view.frame);
            if (height >= CGRectGetHeight(self.view.frame)) {
                self.handleBar.frame = CGRectMake(0,
                                                  CGRectGetHeight(self.view.frame)- inset.bottom - kVideoPlayerViewBarBottom - kVideoPlayerViewBarHeight,
                                                  CGRectGetWidth(self.view.frame),
                                                  kVideoPlayerViewBarHeight);
            }
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - getter
- (YSFVideoPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[YSFVideoPlayer alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_videoPlayer];
    }
    return _videoPlayer;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setImage:[UIImage ysf_imageInKit:@"video_close.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_closeButton aboveSubview:self.videoPlayer];
    }
    return _closeButton;
}

- (UIButton *)closeLargeButton {
    if (!_closeLargeButton) {
        _closeLargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeLargeButton.backgroundColor = [UIColor clearColor];
        [_closeLargeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_closeLargeButton aboveSubview:self.closeButton];
    }
    return _closeLargeButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage ysf_imageInKit:@"video_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_playButton aboveSubview:self.videoPlayer];
    }
    return _playButton;
}

- (YSFVideoHandleBar *)handleBar {
    if (!_handleBar) {
        _handleBar = [[YSFVideoHandleBar alloc] initWithFrame:CGRectZero];
        _handleBar.delegate = self;
        [self.view insertSubview:_handleBar aboveSubview:self.videoPlayer];
    }
    return _handleBar;
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)self.message.messageObject;
    if (!videoObject) {
        return;
    }
    CGSize videoSize = videoObject.coverSize;
    if (videoSize.width == 0 || videoSize.height == 0) {
        videoSize = CGSizeMake(480, 640);
    }
    CGFloat height = (videoSize.height / videoSize.width) * CGRectGetWidth(self.view.frame);
    self.videoPlayer.frame = CGRectMake(0, roundf((CGRectGetHeight(self.view.frame) - height) / 2), CGRectGetWidth(self.view.frame), height);
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.closeButton.frame = CGRectMake(kVideoPlayerViewSpace,
                                        kVideoPlayerViewSpace + statusBarHeight,
                                        kVideoPlayerViewCloseSize,
                                        kVideoPlayerViewCloseSize);
    self.closeLargeButton.frame = CGRectMake(0,
                                             statusBarHeight,
                                             kVideoPlayerViewCloseSize + 2 * kVideoPlayerViewSpace,
                                             kVideoPlayerViewCloseSize + 2 * kVideoPlayerViewSpace);
    self.playButton.bounds = CGRectMake(0, 0, kVideoPlayerViewButtonSize, kVideoPlayerViewButtonSize);
    self.playButton.center = self.view.center;
    self.handleBar.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.videoPlayer.frame) - kVideoPlayerViewBarBottom - kVideoPlayerViewBarHeight,
                                      CGRectGetWidth(self.view.frame),
                                      kVideoPlayerViewBarHeight);
}

- (void)setStatus:(YSFVideoPlayerStatus)status {
    _status = status;
    if (YSFVideoPlayerStatusHidden == status) {
        self.closeButton.hidden = YES;
        self.closeLargeButton.hidden = YES;
        self.playButton.hidden = YES;
        self.handleBar.hidden = YES;
    } else if (YSFVideoPlayerStatusHandle == status) {
        self.closeButton.hidden = NO;
        self.closeLargeButton.hidden = NO;
        self.playButton.hidden = YES;
        self.handleBar.hidden = NO;
        [self startTimer];
    } else if (YSFVideoPlayerStatusDone == status) {
        self.closeButton.hidden = NO;
        self.closeLargeButton.hidden = NO;
        self.playButton.hidden = NO;
        self.handleBar.hidden = NO;
        [self.handleBar updatePlayButton:NO];
    }
}

#pragma mark - action
- (void)clickCloseButton:(id)sender {
    [self.videoPlayer cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickPlayButton:(id)sender {
    self.status = YSFVideoPlayerStatusHidden;
    [self.handleBar updatePlayButton:YES];
    [self.videoPlayer playFromTime:kCMTimeZero];
}

- (void)updateHandleBarWithCurTime:(NSTimeInterval)curTime totalTime:(NSTimeInterval)totalTime {
    [self.handleBar updateCurTime:curTime totalTime:totalTime];
    if (curTime >= totalTime && curTime != 0) {
        self.status = YSFVideoPlayerStatusDone;
    }
}

#pragma mark - Gesture
- (void)tapScreen:(UITapGestureRecognizer *)sender {
    if (YSFVideoPlayerStatusHidden == self.status) {
        self.status = YSFVideoPlayerStatusHandle;
    } else if (YSFVideoPlayerStatusHandle == self.status) {
        self.status = YSFVideoPlayerStatusHidden;
    }
}

- (void)longPressScreen:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        __weak typeof(self) weakSelf = self;
        YSFAlertController * alertController = [YSFAlertController actionSheetWithTitle:nil];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"保存至本地" handler:^(YSFAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)strongSelf.message.messageObject;
            [[YSFVideoDataManager sharedManager] saveVideoToSystemLibrary:videoObject.path completion:nil];
        }]];
        [alertController addCancelActionWithHandler:nil];
        [alertController showWithSender:nil
                         arrowDirection:UIPopoverArrowDirectionAny
                             controller:self
                               animated:YES
                             completion:nil];
    }
}

#pragma mark - timer
- (void)startTimer {
    if (_timer) {
        [_timer stop];
        _timer = nil;
    }
    _timer = [[YSFTimer alloc] init];
    __weak typeof(self) weakSelf = self;
    [_timer start:dispatch_get_main_queue() interval:3.0f repeats:NO block:^{
        if (YSFVideoPlayerStatusHandle == weakSelf.status) {
            weakSelf.status = YSFVideoPlayerStatusHidden;
            [weakSelf stopTimer];
        }
    }];
}

- (void)stopTimer {
    if (_timer && !_timer.isStopped) {
        [_timer stop];
        _timer = nil;
    }
}

#pragma mark - YSFVideoHandleBarDelegate
- (void)playOrPause:(BOOL)play {
    if (play) {
        if (YSFVideoPlayerStatusDone == self.status) {
            self.status = YSFVideoPlayerStatusHandle;
            [self.videoPlayer playFromTime:kCMTimeZero];
        } else {
            [self.videoPlayer play];
        }
    } else {
        [self.videoPlayer pause];
    }
}

@end

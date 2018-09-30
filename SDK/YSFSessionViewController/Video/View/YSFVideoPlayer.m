//
//  YSFVideoPlayer.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoPlayer.h"
#import "YSFVideoDataManager.h"
#import "NIMUtil.h"

@interface YSFVideoPlayer() {
    id _timeObserver;
    NSTimeInterval _totalTime;
    YSFVideoPlayerStatusBlock _block;
    BOOL _soundOff;
}

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation YSFVideoPlayer

- (void)dealloc {
//    NSLog(@"YSFVideoPlayer dealloc");
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _totalTime = 0;
        _block = nil;
        _soundOff = NO;
    }
    return self;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_indicator];
    }
    return _indicator;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    self.indicator.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

#pragma mark - action
- (void)startWithMessage:(YSF_NIMMessage *)message
                soundOff:(BOOL)soundOff
             statusBlock:(YSFVideoPlayerStatusBlock)statusBlock {
    if (!message || YSF_NIMMessageTypeVideo != message.messageType) {
        return;
    }
    YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)message.messageObject;
    NSString *localPath = videoObject.path;
    NSString *remotePath = videoObject.url;
    NSString *coverPath = videoObject.coverPath;
    _block = statusBlock;
    _soundOff = soundOff;
    //显示封面图片
    if (coverPath.length && [[NSFileManager defaultManager] fileExistsAtPath:coverPath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:videoObject.coverPath];
        self.coverImageView.image = image;
    }
    //下载视频
    __weak typeof(self) weakSelf = self;
    [[YSFVideoDataManager sharedManager] downloadVideoDataWithLocalPath:localPath
                                                             remotePath:remotePath
                                                               progress:^(CGFloat progress) {
                                                                   if (progress >= 0) {
                                                                       if (![weakSelf.indicator isAnimating]) {
                                                                           [weakSelf.indicator startAnimating];
                                                                       }
                                                                   }
                                                                   if (progress >= 1) {
                                                                       if ([weakSelf.indicator isAnimating]) {
                                                                           [weakSelf.indicator stopAnimating];
                                                                       }
                                                                   }
                                                               }
                                                             completion:^(BOOL success) {
                                                                 __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                 if (success) {
                                                                     [strongSelf.coverImageView removeFromSuperview];
                                                                     [strongSelf.indicator removeFromSuperview];
                                                                     if (localPath.length) {
                                                                         strongSelf.videoURL = [NSURL fileURLWithPath:localPath];
                                                                         [strongSelf setupPlayer];
                                                                     }
                                                                 }
                                                             }];
    
}

- (void)setupPlayer {
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    if (_soundOff) {
        self.player.muted = YES;
    }
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.playerLayer];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 5)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {
                                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                                             [strongSelf updateHandleBarWithTime:time];
                                                         }];
}

- (void)playFromTime:(CMTime)time {
    if (self.player) {
        if (AVPlayerStatusReadyToPlay == self.player.status) {
            [self.playerItem seekToTime:time];
            [self.player play];
            return;
        }
    }
    [self showToast:@"视频播放错误"];
}

- (void)play {
    [self playFromTime:self.playerItem.currentTime];
}

- (void)pause {
    if (self.player) {
        [self.player pause];
    }
}

- (void)cancel {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem cancelPendingSeeks];
    [self.playerItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    [[YSF_NIMSDK sharedSDK].resourceManager cancelTask:_videoURL.path];
}

- (void)updateHandleBarWithTime:(CMTime)time {
    if (self.playerItem.currentTime.timescale != 0) {
        NSTimeInterval curSecond = CMTimeGetSeconds(self.playerItem.currentTime);
        if (_block) {
            _block(curSecond, _totalTime);
        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (AVPlayerItemStatusUnknown == itemStatus) {
            
        } else if (AVPlayerItemStatusReadyToPlay == itemStatus) {
            if (self.playerItem.asset.duration.timescale != 0) {
                _totalTime = CMTimeGetSeconds(self.playerItem.asset.duration);
            }
            [self playFromTime:kCMTimeZero];
        } else if (AVPlayerItemStatusFailed == itemStatus) {
            
        }
    }
}

#pragma mark - toast
- (void)showToast:(NSString *)string {
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    if (topWindow) {
        [topWindow ysf_makeToast:string duration:2.0f position:YSFToastPositionCenter];
    }
}

@end

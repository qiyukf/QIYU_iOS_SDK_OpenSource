//
//  YSFVideoHandleBar.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/19.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoHandleBar.h"
#import "YSFVideoProgressView.h"

static CGFloat kVideoHandleBarSpace = 15.0f;
static CGFloat kVideoHandleBarButtonGap = 13.0f;
static CGFloat kVideoHandleBarLabelGap = 7.0f;
static CGFloat kVideoHandleBarButtonWidth = 14.0f;
static CGFloat kVideoHandleBarButtonHeight = 18.0f;
static CGFloat kVideoHandleBarLabelWidth = 35.0f;
static CGFloat kVideoHandleBarLabelHeight = 17.0f;
static CGFloat kVideoHandleBarProgressHeight = 6.0f;


@interface YSFVideoHandleBar()

@property (nonatomic, strong) YSFVideoProgressView *progressView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *curTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation YSFVideoHandleBar

- (void)dealloc {
//    NSLog(@"YSFVideoHandleBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (YSFVideoProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[YSFVideoProgressView alloc] init];
        _progressView.progressValue = 0.0;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.userInteractionEnabled = NO;
        [_playButton setImage:[UIImage ysf_imageInKit:@"video_play_start"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage ysf_imageInKit:@"video_play_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    return _playButton;
}

- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clickButton.userInteractionEnabled = YES;
        _clickButton.backgroundColor = [UIColor clearColor];
        [_clickButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_clickButton aboveSubview:self.playButton];
    }
    return _clickButton;
}

- (UILabel *)curTimeLabel {
    if (!_curTimeLabel) {
        _curTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _curTimeLabel.textColor = [UIColor whiteColor];
        _curTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _curTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_curTimeLabel];
    }
    return _curTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_totalTimeLabel];
    }
    return _totalTimeLabel;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.playButton.frame = CGRectMake(kVideoHandleBarSpace,
                                       roundf((CGRectGetHeight(self.frame) - kVideoHandleBarButtonHeight) / 2),
                                       kVideoHandleBarButtonWidth,
                                       kVideoHandleBarButtonHeight);
    self.curTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame) + kVideoHandleBarButtonGap,
                                         roundf((CGRectGetHeight(self.frame) - kVideoHandleBarLabelHeight) / 2),
                                         kVideoHandleBarLabelWidth,
                                         kVideoHandleBarLabelHeight);
    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.curTimeLabel.frame) + kVideoHandleBarLabelGap,
                                         roundf((CGRectGetHeight(self.frame) - kVideoHandleBarProgressHeight) / 2),
                                         CGRectGetWidth(self.frame) - 2 * (kVideoHandleBarSpace + kVideoHandleBarLabelWidth + kVideoHandleBarLabelGap) - kVideoHandleBarButtonWidth - kVideoHandleBarButtonGap,
                                         kVideoHandleBarProgressHeight);
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressView.frame) + kVideoHandleBarLabelGap,
                                           roundf((CGRectGetHeight(self.frame) - kVideoHandleBarLabelHeight) / 2),
                                           kVideoHandleBarLabelWidth,
                                           kVideoHandleBarLabelHeight);
    self.clickButton.frame = CGRectMake(0,
                                        -kVideoHandleBarSpace,
                                        CGRectGetMinX(self.curTimeLabel.frame),
                                        CGRectGetHeight(self.playButton.frame) + 2 * kVideoHandleBarSpace);
}

#pragma mark - action
- (void)updateCurTime:(NSTimeInterval)curTime totalTime:(NSTimeInterval)totalTime {
    if (curTime >= 0 && totalTime > 0) {
        CGFloat value = curTime / totalTime;
        if (value < 0.01) {
            self.progressView.progressValue = 0;
        }
        if (value >= self.progressView.progressValue) {
            self.progressView.progressValue = value;
        }
    }
    NSInteger curSecond = roundf(curTime);
    NSInteger totalSecond = roundf(totalTime);
    self.curTimeLabel.text = [self convertTimeString:curSecond];
    self.totalTimeLabel.text = [self convertTimeString:totalSecond];
}

- (void)updatePlayButton:(BOOL)selected {
    self.playButton.selected = selected;
}

- (void)clickPlayButton:(id)sender {
    _playButton.selected = !_playButton.selected;
    if ([self.delegate respondsToSelector:@selector(playOrPause:)]) {
        [self.delegate playOrPause:_playButton.selected];
    }
}

- (void)clickButton:(id)sender {
    [self clickPlayButton:sender];
}

- (NSString *)convertTimeString:(NSInteger)time {
    NSString *timeStr = @"";
    if (time < 10) {
        timeStr = [NSString stringWithFormat:@"00:0%ld", (long)time];
    } else {
        timeStr = [NSString stringWithFormat:@"00:%ld", (long)time];
    }
    return timeStr;
}

@end

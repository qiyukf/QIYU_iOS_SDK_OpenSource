//
//  NIMInputAudioRecordIndicatorView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputAudioRecordIndicatorView.h"
#import "YSFTimer.h"


#define YSFKit_ViewWidth 148
#define YSFKit_ViewHeight 148

#define YSFKit_TimeFontSize 30
#define YSFKit_TipFontSize 15

@interface YSFInputAudioRecordIndicatorView(){
    UIImageView *_backgrounView;
    UIImageView *_microphoneView;
    UIImageView *_microphoneCancelView;
    UIImageView *_timeOverClock;
    UILabel *_countDownTipNumber;
    UIImageView *_tipBackgroundView;
    YSFTimer *timer;
    YSFTimer *tipTimer;
    BOOL _countdown;
}

@property (nonatomic,strong) UIImageView *microphoneVolumeView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation YSFInputAudioRecordIndicatorView
- (instancetype)init {
    self = [super init];
    if(self) {
        _countdown = NO;
        
        timer = [[YSFTimer alloc] init];
        tipTimer = [[YSFTimer alloc] init];
        _backgrounView = [[UIImageView alloc] initWithImage:[[UIImage ysf_imageInKit:@"icon_input_record_indicator"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_backgrounView];
        
        _microphoneView = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_microphone"]];
        [_backgrounView addSubview:_microphoneView];
        _microphoneCancelView = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_microphone_cancel"]];
        _microphoneCancelView.hidden = YES;
        [_backgrounView addSubview:_microphoneCancelView];
        _microphoneVolumeView = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_microphone_volumn_01"]];
        _microphoneVolumeView.hidden = YES;
        [_backgrounView addSubview:_microphoneVolumeView];
        
        _tipBackgroundView = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_input_record_indicator_cancel"]];
        _tipBackgroundView.hidden = YES;
        [_backgrounView addSubview:_tipBackgroundView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:YSFKit_TipFontSize];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"手指上滑，取消发送";
        [_backgrounView addSubview:_tipLabel];

        _countDownTipNumber = [[UILabel alloc] initWithFrame:CGRectZero];
        _countDownTipNumber.font = [UIFont systemFontOfSize:60];
        _countDownTipNumber.textColor = [UIColor whiteColor];
        _countDownTipNumber.textAlignment = NSTextAlignmentCenter;
        _countDownTipNumber.text = @"10";
        _countDownTipNumber.hidden = YES;
        [_backgrounView addSubview:_countDownTipNumber];

        _timeOverClock = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_clock"]];
        _timeOverClock.hidden = YES;
        [_backgrounView addSubview:_timeOverClock];
        
        self.phase = AudioRecordPhaseEnd;
    }
    return self;
}

- (void)setPhase:(NIMAudioRecordPhase)phase {
    if(phase == AudioRecordPhaseStart) {
        __weak typeof(self) weakSelf = self;
        [timer start:dispatch_get_main_queue() interval:1 repeats:YES block :^{ [weakSelf updateMicrophoneVolumn]; }];
        [tipTimer start:dispatch_get_main_queue() startAfter:49 interval:1 repeats:YES block :^{ [weakSelf updateTip]; }];
    }
    else if(phase == AudioRecordPhaseCancelling) {
        _tipLabel.text = @"松开手指，取消发送";
        _tipBackgroundView.hidden = NO;

        if (!_countdown) {
            _microphoneCancelView.hidden = NO;
            _microphoneView.hidden = YES;
            _microphoneVolumeView.hidden = YES;
        }
    }
    else {
        _tipLabel.text = @"手指上滑，取消发送";
        _tipBackgroundView.hidden = YES;

        if (!_countdown) {
            _microphoneCancelView.hidden = YES;
            _microphoneView.hidden = NO;
            _microphoneVolumeView.hidden = NO;
            
            if (phase == AudioRecordPhaseEnd) {
                [timer stop];
            }
        }
    }
}

- (void) updateTip
{
    if (!_countdown) {
        _countdown = YES;
        _microphoneCancelView.hidden = YES;
        _microphoneView.hidden = YES;
        _microphoneVolumeView.hidden = YES;
        _countDownTipNumber.hidden = NO;
    }
    else {
        int intString = [ _countDownTipNumber.text intValue];
        intString -= 1;
        if (intString > 0) {
            NSString *newStringInt = [NSString stringWithFormat:@"%d",intString];
            _countDownTipNumber.text = newStringInt;
        }
        else if (intString == 0) {
            _timeOverClock.hidden = NO;
            _countDownTipNumber.hidden = YES;
            _tipLabel.text = @"说话时间已到60秒";
        }
    }

}

- (void) updateMicrophoneVolumn
{
    float power = [[[YSF_NIMSDK sharedSDK] mediaManager] recordAveragePower];
    float _s = self.frame.size.width*0.25/320;
    float volum = (power + 40)*_s;
    if (volum < 0) {
        volum = 0;
    }
    float scale = volum/5;
    int volumnPicIndex = 0;
    if (scale < 0.1) {
        volumnPicIndex = 1;
    }
    else if (scale < 0.3)
    {
        volumnPicIndex = 2;
    }
    else if (scale < 0.5)
    {
        volumnPicIndex = 3;
    }
    else if (scale < 0.7)
    {
        volumnPicIndex = 4;
    }
    else if (scale < 0.9)
    {
        volumnPicIndex = 5;
    }
    else
    {
        volumnPicIndex = 6;
    }
    NSString *stringInt = [NSString stringWithFormat:@"icon_microphone_volumn_0%d",volumnPicIndex];
    self.microphoneVolumeView.image = [UIImage ysf_imageInKit:stringInt];
}

- (void)layoutSubviews {
    self.frame = CGRectMake(0, 0, YSFUIScreenWidth, YSFUIScreenHeight);
    _backgrounView.ysf_frameWidth = YSFKit_ViewWidth;
    _backgrounView.ysf_frameHeight = YSFKit_ViewHeight;
    _tipBackgroundView.frame = CGRectMake(0, YSFKit_ViewHeight - CGRectGetHeight(_tipBackgroundView.bounds), YSFKit_ViewWidth, CGRectGetHeight(_tipBackgroundView.bounds));
    
    _backgrounView.center = self.center;
    CGRect microphoneRect = _microphoneView.frame;
    microphoneRect.origin = CGPointMake(35, 30);
    _microphoneView.frame = microphoneRect;
    [_microphoneCancelView sizeToFit];
    _microphoneCancelView.ysf_frameTop = 30;
    _microphoneCancelView.ysf_frameCenterX = _backgrounView.ysf_frameWidth / 2;
    [_timeOverClock sizeToFit];
    _timeOverClock.ysf_frameTop = 30;
    _timeOverClock.ysf_frameCenterX = _backgrounView.ysf_frameWidth / 2;
    _countDownTipNumber.ysf_frameSize = CGSizeMake(200, 80);
    _countDownTipNumber.ysf_frameCenterX = _backgrounView.ysf_frameWidth / 2;
    _countDownTipNumber.ysf_frameTop = 30;
    CGRect microphoneVolumeRect = _microphoneVolumeView.frame;
    microphoneVolumeRect.origin = CGPointMake(95, 54);
    _microphoneVolumeView.frame = microphoneVolumeRect;
    CGSize size = [_tipLabel sizeThatFits:CGSizeMake(YSFKit_ViewWidth, MAXFLOAT)];
    _tipLabel.frame = CGRectMake(0, YSFKit_ViewHeight - 10 - size.height, YSFKit_ViewWidth, size.height);
}


@end

#import "YSFRecordTipView.h"
#import "YSFTimer.h"
#import "YSFAttributedLabel.h"
#import "QYCustomUIConfig.h"

@interface YSFRecordTipView ()
{
    UIImageView *_receiver;
    UIImageView *_speaker;
    YSFAttributedLabel *_tipLabel;
    YSFTimer *_timer;
}
@end

@implementation YSFRecordTipView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = YSFRGBA2(0xb2000000);
        _timer = [[YSFTimer alloc] init];
        _receiver = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_receiver"]];
        [self addSubview:_receiver];
        _speaker = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_speaker"]];
        [self addSubview:_speaker];
        
        _tipLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        CGFloat textFontSize = [[QYCustomUIConfig sharedInstance] sessionTipTextFontSize];
        [_tipLabel setFont:[UIFont systemFontOfSize:textFontSize]];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_tipLabel];
        self.hidden = YES;
    }
    return self;
}

- (void) setReceiverOrSpeaker:(YSF_TipType) tipType
{
    if (tipType == YSF_TipTypeCurrentModeReceiver) {
        _receiver.hidden = NO;
        _speaker.hidden = YES;
        [_tipLabel setText:@"当前为听筒模式"];
    }
    else if (tipType == YSF_TipTypeCurrentModeSpeaker) {
        _receiver.hidden = YES;
        _speaker.hidden = NO;
        [_tipLabel setText:@"当前为扬声器模式"];
    }
    else if (tipType == YSF_TipTypeCurrentPlayingReceiver) {
        _receiver.hidden = NO;
        _speaker.hidden = YES;
        [_tipLabel setText:@"正在使用听筒播放"];
    }
    else if (tipType == YSF_TipTypeCurrentPlayingSpeaker) {
        _receiver.hidden = YES;
        _speaker.hidden = NO;
        [_tipLabel setText:@"正在使用扬声器播放"];
    }
    
    self.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [_timer start:dispatch_get_main_queue() interval:3 repeats:NO block:^{
        weakSelf.hidden = YES;
    }];
}

- (void)layoutSubviews {
    _receiver.ysf_frameLeft = 20;
    _receiver.ysf_frameTop = 6;
    _speaker.ysf_frameLeft = 20;
    _speaker.ysf_frameTop = 10;
    _tipLabel.ysf_frameHeight = self.ysf_frameHeight;
    _tipLabel.ysf_frameTop = 10;
    _tipLabel.ysf_frameLeft = 60;
    _tipLabel.ysf_frameWidth = self.ysf_frameWidth - _tipLabel.ysf_frameLeft - 10 - 10;
}

-(void)onTapClose:(id)sender
{
    self.hidden = YES;
}

@end

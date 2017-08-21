//
//  SessionAudioCententView.m
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionAudioContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "NSDictionary+YSFJson.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"

@interface YSFSessionAudioContentView()<YSF_NIMMediaManagerDelgate>

@property (nonatomic,strong) UIImageView *voiceImageView;

@property (nonatomic,strong) UILabel *durationLabel;
@property (nonatomic,strong) UIView *separateView;
@property (nonatomic,strong) UIButton *textLabel;
@property (nonatomic,strong) UIButton *failedButton;
@property (nonatomic, strong) UIActivityIndicatorView *traningActivityIndicator;

@end

@implementation YSFSessionAudioContentView

-(instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        [self addVoiceView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addVoiceView {
    _voiceImageView = [[UIImageView alloc] init];
    _voiceImageView.animationDuration = 1.0;
    [self addSubview:_voiceImageView];

    _separateView = [[UIImageView alloc] init];
    _separateView.backgroundColor = YSFColorFromRGB(0x5194D2);
    _separateView.hidden = YES;
    [self addSubview:_separateView];
    
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _durationLabel.backgroundColor = [UIColor clearColor];
    _durationLabel.font = [UIFont systemFontOfSize:14.f];
    [self addSubview:_durationLabel];
    
    _textLabel = [[UIButton alloc] initWithFrame:CGRectZero];
    [_textLabel addTarget:self action:@selector(onRetryAudioToText:) forControlEvents:UIControlEventTouchUpInside];
    _textLabel.titleLabel.numberOfLines = 0;
    _textLabel.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self addSubview:_textLabel];
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
    NSMutableArray * animationImages = nil;
    NSArray * animateNames = nil;
    if (([YSF_NIMSDK sharedSDK].sdkOrKf && self.model.message.isOutgoingMsg)
        || (![YSF_NIMSDK sharedSDK].sdkOrKf && !self.model.message.isOutgoingMsg)) {
        _voiceImageView.image = [UIImage ysf_imageInKit:@"icon_customer_voice_playing.png"];
        animateNames = @[@"icon_customer_voice_playing_001.png",@"icon_customer_voice_playing_002.png",@"icon_customer_voice_playing_003.png"];
    }
    else {
        _voiceImageView.image = [UIImage ysf_imageInKit:@"icon_service_voice_playing.png"];
        animateNames = @[@"icon_service_voice_playing_001.png",@"icon_service_voice_playing_002.png",@"icon_service_voice_playing_003.png"];
    }
    animationImages = [[NSMutableArray alloc] initWithCapacity:animateNames.count];
    for (NSString * animateName in animateNames) {
        UIImage * animateImage = [UIImage ysf_imageInKit:animateName];
        [animationImages addObject:animateImage];
    }
    [_voiceImageView sizeToFit];
    _voiceImageView.animationImages = animationImages;
    
    YSF_NIMAudioObject *object = self.model.message.messageObject;
    _durationLabel.text = [NSString stringWithFormat:@"%zd\"",(object.duration+500)/1000];
    if (!self.model.message.isOutgoingMsg) {
        _durationLabel.textColor = [QYCustomUIConfig sharedInstance].serviceMessageTextColor;
        [_textLabel setTitleColor:[QYCustomUIConfig sharedInstance].serviceMessageTextColor forState:UIControlStateNormal];
    }else{
        _durationLabel.textColor = [QYCustomUIConfig sharedInstance].customMessageTextColor;
        [_textLabel setTitleColor:[QYCustomUIConfig sharedInstance].customMessageTextColor forState:UIControlStateNormal];
    }
    [_durationLabel sizeToFit];

    [_traningActivityIndicator removeFromSuperview];
    _traningActivityIndicator = nil;
    [_failedButton removeFromSuperview];
    _failedButton = nil;
    NSDictionary *dict = [self.model.message.ext ysf_toDict];
    NSString *text = [dict ysf_jsonString:YSFApiKeyContent];
    _separateView.hidden = YES;
    if (self.model.message.ext.length > 0 && ![YSF_NIMSDK sharedSDK].sdkOrKf && !self.model.message.isOutgoingMsg) {
        _separateView.hidden = NO;
        if (text == nil) {
            if ([[KFAudioToTextHandler sharedInstance] audioInTransfering:self.model.message.messageId]) {
                text = @"文字转换中...";
                
                _traningActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20,20)];
                [self addSubview:_traningActivityIndicator];
                [_traningActivityIndicator startAnimating];
            }
            else {
                text = @"文字转换失败，点击重新转换";
                
                _failedButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
                [_failedButton setImage:[UIImage ysf_imageInKit:@"icon_message_cell_error"] forState:UIControlStateNormal];
                [self addSubview:_failedButton];
            }
        }
        else if (text.length == 0) {
            text = @" ";
        }
        
        _textLabel.hidden = NO;
        [_textLabel setTitle:text forState:UIControlStateNormal];
    }
    else {
        _textLabel.hidden = YES;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    if (self.model.message.isOutgoingMsg) {
        self.voiceImageView.ysf_frameRight = self.ysf_frameWidth - contentInsets.right;
        _durationLabel.ysf_frameLeft = contentInsets.left;
    }
    else
    {
       self.voiceImageView.ysf_frameLeft = contentInsets.left;
        _durationLabel.ysf_frameRight = self.ysf_frameWidth - contentInsets.right;
    }
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _voiceImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    _voiceImageView.ysf_frameTop = 14;
    _durationLabel.ysf_frameTop = 14;
    
    _traningActivityIndicator.ysf_frameLeft = contentInsets.left;
    _traningActivityIndicator.ysf_frameTop = 50;
    _failedButton.ysf_frameLeft = contentInsets.left;
    _failedButton.ysf_frameTop = 50;
    CGSize contentsize         = self.model.contentSize;
    CGSize size = CGSizeZero;
    if (_traningActivityIndicator || _failedButton) {
        size = [_textLabel.titleLabel sizeThatFits:CGSizeMake(contentsize.width - 25, CGFLOAT_MAX)];
    }
    else {
        size = [_textLabel.titleLabel sizeThatFits:CGSizeMake(contentsize.width, CGFLOAT_MAX)];
    }
    
    _separateView.ysf_frameWidth = self.ysf_frameWidth - 5;
    _separateView.ysf_frameLeft = 5;
    _separateView.ysf_frameTop = contentInsets.top + 23 + 10;
    _separateView.ysf_frameHeight = 1;
    _textLabel.ysf_frameLeft = contentInsets.left;
    _textLabel.ysf_frameTop = contentInsets.top + 23 + 20;
    _textLabel.ysf_frameWidth = size.width;
    _textLabel.ysf_frameHeight = size.height;
    if (_traningActivityIndicator) {
        _textLabel.ysf_frameLeft = _traningActivityIndicator.ysf_frameRight + 5;
    }
    if (_failedButton) {
        _textLabel.ysf_frameLeft = _failedButton.ysf_frameRight + 5;
    }
}

-(void)onTouchUpInside:(id)sender
{
    if ([self.model.message attachmentDownloadState]== YSF_NIMMessageAttachmentDownloadStateFailed) {
        if (self.audioUIDelegate && [self.audioUIDelegate respondsToSelector:@selector(retryDownloadMsg)]) {
            [self.audioUIDelegate retryDownloadMsg];
        }
        return;
    }
    if ([self.model.message attachmentDownloadState] == YSF_NIMMessageAttachmentDownloadStateDownloaded) {
        if (![[YSF_NIMSDK sharedSDK].mediaManager isPlaying]) {
            YSFKitEvent *event = [[YSFKitEvent alloc] init];
            event.eventName = YSFKitEventNameTapContent;
            event.message = self.model.message;
            event.data = sender;
            [self.delegate onCatchEvent:event];
            
            YSF_NIMAudioObject *audioObject = (YSF_NIMAudioObject*)event.message.messageObject;
            [[YSF_NIMSDK sharedSDK].mediaManager playAudio:audioObject.path withDelegate:self];
        }
        else {
            [[YSF_NIMSDK sharedSDK].mediaManager stopPlay];
            [self stopPlayingUI];
        }
    }
}

-(void)onRetryAudioToText:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapRetryAudioToText;
    event.message = self.model.message;
    event.data = sender;
    [self.delegate onCatchEvent:event];
}

#pragma mark - YSF_NIMMediaManagerDelgate

- (void)playAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if(filePath && !error) {
        if (self.audioUIDelegate && [self.audioUIDelegate respondsToSelector:@selector(startPlayingAudioUI)]) {
            [self.audioUIDelegate startPlayingAudioUI];
            [self.voiceImageView startAnimating];
        }
    }
}

- (void)playAudio:(NSString *)filePath didCompletedWithError:(NSError *)error
{
    [self stopPlayingUI];
}

#pragma mark - private methods
- (void)stopPlayingUI
{
    [self.voiceImageView stopAnimating];
}
@end

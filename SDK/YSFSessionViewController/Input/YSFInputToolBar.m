//
//  NIMInputToolBar.m
//  YSFKit
//
//  Created by chris
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputToolBar.h"
#import "YSFInputTextView.h"
#import "QYCustomUIConfig.h"

@interface YSFInputToolBar()
@property (nonatomic,strong) UIView *topSep;

@end

@implementation YSFInputToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _humanOrMachine = YES;
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn setImage:[UIImage ysf_imageInKit:@"icon_toolview_voice_normal"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage ysf_imageInKit:@"icon_toolview_voice_pressed"] forState:UIControlStateHighlighted];
        _voiceBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        [_voiceBtn sizeToFit];
        _voiceBtn.ysf_frameSize = CGSizeMake(_voiceBtn.ysf_frameWidth + 14, _voiceBtn.ysf_frameHeight + 14);
        _voiceBtn.hidden = ![QYCustomUIConfig sharedInstance].showAudioEntry;
        [self addSubview:_voiceBtn];
        
        _emoticonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emoticonBtn setImage:[UIImage ysf_imageInKit:@"icon_toolview_emotion_normal"] forState:UIControlStateNormal];
        [_emoticonBtn setImage:[UIImage ysf_imageInKit:@"icon_toolview_emotion_pressed"] forState:UIControlStateHighlighted];
        _emoticonBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        [_emoticonBtn sizeToFit];
        _emoticonBtn.ysf_frameSize = CGSizeMake(_emoticonBtn.ysf_frameWidth + 14, _emoticonBtn.ysf_frameHeight + 14);
        _emoticonBtn.hidden = ![QYCustomUIConfig sharedInstance].showEmoticonEntry;
        [self addSubview:_emoticonBtn];
        
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setImage:[[UIImage ysf_imageInKit:@"icon_input_text_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_recordButton setImage:[[UIImage ysf_imageInKit:@"icon_input_audio_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
        [_recordButton sizeToFit];
        _recordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _recordButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [self addSubview:_recordButton];
        
        _recordLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _recordLabel.font = [UIFont systemFontOfSize:14.f];
        _recordLabel.textColor = [UIColor blackColor];
        _recordLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_recordLabel];
        
        _inputTextBkgImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_inputTextBkgImage setImage:[[UIImage ysf_imageInKit:@"icon_input_text_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_inputTextBkgImage];
        
        _inputTextView = [[YSFInputTextView alloc] initWithFrame:CGRectZero];
        _inputTextView.enablesReturnKeyAutomatically = YES;
        [self addSubview:_inputTextView];
        
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setImage:[UIImage ysf_imageInKit:@"icon_send_image_normal"] forState:UIControlStateNormal];
        [_imageButton setImage:[UIImage ysf_imageInKit:@"icon_send_image_pressed"] forState:UIControlStateHighlighted];
        _imageButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        [_imageButton sizeToFit];
        _imageButton.ysf_frameSize = CGSizeMake(_imageButton.ysf_frameWidth + 14, _imageButton.ysf_frameHeight + 14);
        [self addSubview:_imageButton];
        
        _topSep = [[UIView alloc] initWithFrame:CGRectZero];
        _topSep.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self addSubview:_topSep];
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat height = 50.f;
    return CGSizeMake(size.width,height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat leftSpacing           = 12.5f;
    CGFloat sepHeight             = .5f;
    CGFloat topSepMargin          = .0f;
    CGFloat spacing               = 9.f;
    CGFloat textViewMargin        = 0.f;
    
    //左边话筒按钮
    self.voiceBtn.ysf_frameLeft        = leftSpacing - 7;
    self.voiceBtn.ysf_frameBottom     = self.ysf_frameHeight - 2;
    
    if (_humanOrMachine) {
        //中间输入框按钮
        self.inputTextBkgImage.ysf_frameWidth     = self.ysf_frameWidth - 3*leftSpacing - [self.imageButton ysf_frameWidth] + 14;
        if (!_voiceBtn.hidden) {
            self.inputTextBkgImage.ysf_frameWidth      += -self.voiceBtn.ysf_frameWidth - leftSpacing + 14;
        }
        if (!_emoticonBtn.hidden) {
            self.inputTextBkgImage.ysf_frameWidth      += -self.emoticonBtn.ysf_frameWidth - leftSpacing + 14;
        }
        self.inputTextBkgImage.ysf_frameHeight    = self.ysf_frameHeight - spacing * 2;
        self.inputTextBkgImage.ysf_frameLeft      = leftSpacing;
        if (!_voiceBtn.hidden) {
            self.inputTextBkgImage.ysf_frameLeft      += self.voiceBtn.ysf_frameRight - 7;
        }
        self.inputTextBkgImage.ysf_frameCenterY   = self.ysf_frameHeight * .5f;
        self.inputTextView.frame = CGRectInset(self.inputTextBkgImage.frame, textViewMargin, textViewMargin);
    }
    else {
        //中间输入框按钮
        self.inputTextBkgImage.ysf_frameWidth     = self.ysf_frameWidth - 2 * leftSpacing;
        if (!_voiceBtn.hidden) {
            self.inputTextBkgImage.ysf_frameWidth      += -self.voiceBtn.ysf_frameWidth - leftSpacing + 14;
        }
        self.inputTextBkgImage.ysf_frameHeight    = self.ysf_frameHeight - spacing * 2;
        self.inputTextBkgImage.ysf_frameLeft      = leftSpacing;
        if (!_voiceBtn.hidden) {
            self.inputTextBkgImage.ysf_frameLeft      += self.voiceBtn.ysf_frameRight - 7;
        }
        self.inputTextBkgImage.ysf_frameCenterY   = self.ysf_frameHeight * .5f;
        self.inputTextView.frame = CGRectInset(self.inputTextBkgImage.frame, textViewMargin, textViewMargin);
    }
    
    //中间点击录音按钮
    self.recordButton.frame    = self.inputTextBkgImage.frame;
    self.recordButton.ysf_frameTop = self.recordButton.ysf_frameTop - 7;
    self.recordButton.ysf_frameHeight = self.recordButton.ysf_frameHeight + 14;
    self.recordButton.imageEdgeInsets = UIEdgeInsetsMake(7, 0, 7, 0);
    self.recordLabel.frame    = self.recordButton.frame;

    //右边表情按钮
    self.emoticonBtn.ysf_frameLeft     = self.recordButton.ysf_frameRight + leftSpacing - 7;
    self.emoticonBtn.ysf_frameBottom     = self.ysf_frameHeight - 2;
    
    self.imageButton.ysf_frameRight      = self.ysf_frameWidth - leftSpacing + 7;
    self.imageButton.ysf_frameBottom     = self.ysf_frameHeight - 2;
    
    //底部分割线
    _topSep.ysf_frameSize        = CGSizeMake(self.ysf_frameWidth, sepHeight);
    _topSep.ysf_frameTop         = topSepMargin;
}

- (void)setHumanOrMachine:(BOOL)humanOrMachine
{
    _humanOrMachine = humanOrMachine;
    if (humanOrMachine) {
        self.voiceBtn.hidden = ![QYCustomUIConfig sharedInstance].showAudioEntry;
    }
    else {
        self.voiceBtn.hidden = ![QYCustomUIConfig sharedInstance].showAudioEntryInRobotMode;
    }
    if ([QYCustomUIConfig sharedInstance].showEmoticonEntry) {
        self.emoticonBtn.hidden = !humanOrMachine;
    }
    self.imageButton.hidden = !humanOrMachine;
    [self setNeedsLayout];
}
@end

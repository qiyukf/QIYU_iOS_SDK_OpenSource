//
//  NIMSessionVideoContentView.m
//  YSFKit
//
//  Created by chris on 15/4/10.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionVideoContentView.h"
#import "YSFMessageModel.h"
#import "YSFLoadProgressView.h"


@interface YSFSessionVideoContentView()

@property (nonatomic,strong,readwrite) UIImageView * imageView;

@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) YSFLoadProgressView * progressView;

@end

@implementation YSFSessionVideoContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        self.opaque = YES;
        _imageView  = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_imageView];
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage ysf_imageInKit:@"icon_play_normal"] forState:UIControlStateNormal];
        [_playBtn sizeToFit];
        [_playBtn setUserInteractionEnabled:NO];
        [self addSubview:_playBtn];
        
        _progressView = [[YSFLoadProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _progressView.maxProgress = 1.0;
        [self addSubview:_progressView];

        
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    YSF_NIMVideoObject * videoObject = (YSF_NIMVideoObject*)self.model.message.messageObject;
    UIImage * image              = [UIImage imageWithContentsOfFile:videoObject.coverPath];
    self.imageView.image         = image;
    _progressView.hidden         = (self.model.message.deliveryState != YSF_NIMMessageDeliveryStateDelivering);
    if (!_progressView.hidden) {
        [_progressView setProgress:[[[YSF_NIMSDK sharedSDK] chatManager] messageTransportProgress:self.model.message]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentsize = self.model.contentSize;
    CGRect imageViewFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.imageView.frame  = imageViewFrame;
    _progressView.frame   = self.bounds;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.cornerRadius = 13.0;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.frame = self.imageView.bounds;
    self.imageView.layer.mask = maskLayer;
    
    self.playBtn.ysf_frameCenterX = self.ysf_frameWidth  * .5f;
    self.playBtn.ysf_frameCenterY = self.ysf_frameHeight * .5f;
}


- (void)onTouchUpInside:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapContent;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
}

- (void)updateProgress:(float)progress
{
    if (progress > 1.0) {
        progress = 1.0;
    }
    self.progressView.progress = progress;
}



@end

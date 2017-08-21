//
//  NIMSessionImageContentView.m
//  YSFKit
//
//  Created by chris on 15/1/28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionImageContentView.h"
#import "YSFMessageModel.h"
#import "YSFLoadProgressView.h"

@interface YSFSessionImageContentView()

@property (nonatomic,strong,readwrite) UIImageView * imageView;

@property (nonatomic,strong) YSFLoadProgressView * progressView;

@end

@implementation YSFSessionImageContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        self.opaque = YES;
        _imageView  = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = YSFRGB(0xf8f8f8);
        [self addSubview:_imageView];
        _progressView = [[YSFLoadProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _progressView.maxProgress = 1.0f;
        [self addSubview:_progressView];

    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    YSF_NIMImageObject * imageObject = (YSF_NIMImageObject*)self.model.message.messageObject;
    UIImage * image              = [UIImage imageWithContentsOfFile:imageObject.thumbPath];
    self.imageView.image         = image;
    self.progressView.hidden     = self.model.message.isOutgoingMsg ? (self.model.message.deliveryState != YSF_NIMMessageDeliveryStateDelivering) : (self.model.message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateDownloading);
    if (!self.progressView.hidden) {
        [self.progressView setProgress:[[[YSF_NIMSDK sharedSDK] chatManager] messageTransportProgress:self.model.message]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _progressView.frame   = self.bounds;
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentSize = self.model.contentSize;
    CGRect imageViewFrame = CGRectMake(contentInsets.left, contentInsets.top, contentSize.width, contentSize.height);
    self.imageView.frame  = imageViewFrame;
    self.imageView.layer.mask = [self.bubbleImageView layer];
}


- (void)onTouchUpInside:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapContent;
    event.message = self.model.message;
    event.data = sender;
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

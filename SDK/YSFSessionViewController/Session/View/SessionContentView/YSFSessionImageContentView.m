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
#import "UIControl+BlocksKit.h"
#import "YSF_NIMMessage+YSF.h"

@interface YSFSessionImageContentView()

@property (nonatomic,strong,readwrite) UIImageView * imageView;
@property (nonatomic, strong) UIView *splitLine;
@property (nonatomic, strong) UIButton *action;
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
        
        _splitLine = [UIView new];
        _splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        [self addSubview:_splitLine];
        
        _action = [UIButton new];
        [_action setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_action ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf actionClick:weakSelf.model.message.actionUrl];
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_action];
        
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
    
    if (self.model.message.isPushMessageType
        && self.model.message.actionText.length) {
        _splitLine.hidden = NO;
        _action.hidden = NO;
        [_action setTitle:self.model.message.actionText forState:UIControlStateNormal];
        _action.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    else {
        _splitLine.hidden = YES;
        _action.hidden = YES;
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
    
    if (self.model.message.isPushMessageType
        && self.model.message.actionText.length) {
        _imageView.ysf_frameHeight -= 44;
        _splitLine.ysf_frameTop = _imageView.ysf_frameBottom;
        _splitLine.ysf_frameHeight = 0.5;
        _splitLine.ysf_frameLeft = 5;
        _splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.ysf_frameLeft = 5;
        _action.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.ysf_frameTop = _splitLine.ysf_frameBottom;
        _action.ysf_frameHeight = 44;
        if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
            _splitLine.ysf_frameLeft = -5;
            _action.ysf_frameLeft = -5;
        }
    }
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

- (void)actionClick:(NSString *)actionUrl
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapPushMessageActionUrl;
    event.message = self.model.message;
    event.data = actionUrl;
    [self.delegate onCatchEvent:event];
}

@end

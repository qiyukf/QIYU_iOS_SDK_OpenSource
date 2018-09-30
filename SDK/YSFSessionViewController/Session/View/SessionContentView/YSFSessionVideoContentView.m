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
#import "UIImageView+YSFWebCache.h"

static CGFloat kVideoContentViewLabelLeftSpace = 5.0f;
static CGFloat kVideoContentViewLabelBottomSpace = 3.0f;
static CGFloat kVideoContentViewLabelHeight = 21.0f;

@interface YSFSessionVideoContentView()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) YSFLoadProgressView * progressView;

@end

@implementation YSFSessionVideoContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        self.opaque = YES;
        _imageView  = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = YSFRGB(0xf8f8f8);
        [self addSubview:_imageView];
        
        _progressView = [[YSFLoadProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _progressView.maxProgress = 1.0;
        [self addSubview:_progressView];

        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage ysf_imageInKit:@"video_message_play"] forState:UIControlStateNormal];
        _playButton.userInteractionEnabled = NO;
        [self addSubview:_playButton];
        
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.font = [UIFont systemFontOfSize:12.0f];
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        [_imageView addSubview:_sizeLabel];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [_imageView addSubview:_timeLabel];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    YSF_NIMMessage *message = self.model.message;
    YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)message.messageObject;
    
    self.imageView.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageWithContentsOfFile:videoObject.coverPath];
    if (image) {
        self.imageView.image = image;
    } else {
        __weak typeof(self) weakSelf = self;
        [self.imageView ysf_setImageWithURL:[NSURL URLWithString:videoObject.coverPath]
                           placeholderImage:nil
                                  completed:^(UIImage *image, NSError * error, YSFImageCacheType cacheType, NSURL * imageURL) {
                                      if (!image) {
                                          weakSelf.imageView.backgroundColor = [UIColor blackColor];
                                      }
                                  }];
    }
    
    BOOL isOutMsg = message.isOutgoingMsg; //是否是往外发的消息
    BOOL isTranDone = isOutMsg ? (message.deliveryState != YSF_NIMMessageDeliveryStateDelivering) : (message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateDownloading);
    self.progressView.hidden = isTranDone;
    if (!self.progressView.hidden) {
        CGFloat value = [[[YSF_NIMSDK sharedSDK] chatManager] messageTransportProgress:message];
        [self.progressView setProgress:value];
    }
    
    self.playButton.hidden = !isTranDone;
    self.sizeLabel.hidden = !isTranDone;
    self.timeLabel.hidden = !isTranDone;
    if (isTranDone) {
        //sizeLabel
        NSString *sizeStr = nil;
        CGFloat size_KB = ((double)videoObject.fileLength) / (1024);
        CGFloat size_MB = ((double)videoObject.fileLength) / (1024 * 1024);
        if (size_KB < 100) {
            sizeStr = [NSString stringWithFormat:@"%ldK", (long)size_KB];
        } else {
            sizeStr = [NSString stringWithFormat:@"%.1fM", size_MB];
        }
        self.sizeLabel.text = sizeStr;
        //timeLabel
        NSInteger second = round(videoObject.duration / 1000.0);
        NSString *timeStr = @"";
        if (second < 10) {
            timeStr = [NSString stringWithFormat:@"00:0%ld", (long)second];
        } else {
            timeStr = [NSString stringWithFormat:@"00:%ld", (long)second];
        }
        self.timeLabel.text = timeStr;
        
        NSString *sourcePath = message.ext;
        if (sourcePath.length) {
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:sourcePath]) {
                [manager removeItemAtPath:sourcePath error:nil];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressView.frame = self.bounds;
    
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentsize = self.model.contentSize;
    CGRect imageViewFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.imageView.frame = imageViewFrame;
    self.imageView.layer.mask = [self.bubbleImageView layer];
    
    CGFloat gap = self.model.message.isOutgoingMsg ? 0 : 4;
    self.sizeLabel.frame = CGRectMake(kVideoContentViewLabelLeftSpace + gap,
                                      CGRectGetHeight(self.imageView.frame) - kVideoContentViewLabelHeight - kVideoContentViewLabelBottomSpace,
                                      CGRectGetWidth(self.imageView.frame) - 2 * kVideoContentViewLabelLeftSpace - 4,
                                      kVideoContentViewLabelHeight);
    self.timeLabel.frame = self.sizeLabel.frame;
    
    UIImage *image = [self.playButton imageForState:UIControlStateNormal];
    self.playButton.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    self.playButton.center = CGPointMake(CGRectGetWidth(self.frame) / 2 + gap, CGRectGetHeight(self.frame) / 2);
    
    if (CGRectGetMinY(self.sizeLabel.frame) - CGRectGetMaxY(self.playButton.frame) < 12) {
        self.playButton.center = CGPointMake(CGRectGetWidth(self.frame) / 2 + gap, CGRectGetHeight(self.frame) / 2 - 5);
    }
}


- (void)onTouchUpInside:(id)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapContent;
    event.message = self.model.message;
    event.data = sender;
    [self.delegate onCatchEvent:event];
}

- (void)updateProgress:(float)progress {
    if (progress > 1.0) {
        progress = 1.0;
    }
    self.progressView.progress = progress;
}

@end

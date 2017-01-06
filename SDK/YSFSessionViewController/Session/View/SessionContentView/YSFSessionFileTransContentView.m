//
//  NIMSessionFileTransContentView.m
//  NIM
//
//  Created by chris on 15/4/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionFileTransContentView.h"
#import "YSFMessageModel.h"


@interface YSFSessionFileTransContentView()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *sizeLabel;

@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,strong) UIView *bkgView;

@end

@implementation YSFSessionFileTransContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        self.opaque              = YES;
        _bkgView                 = [[UIView alloc]initWithFrame:CGRectZero];
        _bkgView.userInteractionEnabled = NO;
        _bkgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bkgView];
        _imageView               = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage * image          = [UIImage ysf_imageInKit:@"icon_file"];
        _imageView.image         = image;
        [_imageView sizeToFit];
        [self addSubview:_imageView];
        _titleLabel               = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font          = [UIFont systemFontOfSize:15.f];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_titleLabel];
        _sizeLabel           = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font      = [UIFont systemFontOfSize:13.f];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_sizeLabel];
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0.0f;
        [self addSubview:_progressView];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)self.model.message.messageObject;
    self.titleLabel.text = fileObject.displayName;
    [self.titleLabel sizeToFit];
    self.sizeLabel.text = [NSString stringWithFormat:@"%zdKB",fileObject.fileLength/1024];
    [self.sizeLabel sizeToFit];
    if (self.model.message.deliveryState == YSF_NIMMessageDeliveryStateDelivering) {
        self.progressView.hidden   = NO;
        self.progressView.progress = [[YSF_NIMSDK sharedSDK].chatManager messageTransportProgress:self.model.message];
    }else{
        self.progressView.hidden = YES;
    }
}



- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize size = self.model.contentSize;
    CGRect bkgViewFrame = CGRectMake(contentInsets.left, contentInsets.top, size.width, size.height);
    self.bkgView.frame = bkgViewFrame;

    CGFloat fileTransMessageIconLeft        = 15.f;
    CGFloat fileTransMessageSizeTitleRight  = 15.f;
    CGFloat fileTransMessageTitleLeft       = 90.f;
    CGFloat fileTransMessageTitleTop        = 25.f;
    CGFloat fileTransMessageSizeTitleBottom = 15.f;
    CGFloat fileTransMessageProgressTop     = 75.f;
    CGFloat fileTransMessageProgressLeft    = 90.f;
    CGFloat fileTransMessageProgressRight   = 20.f;

    self.imageView.ysf_frameLeft          = fileTransMessageIconLeft;
    self.imageView.ysf_frameCenterY       = self.ysf_frameHeight * .5f;

    if (self.ysf_frameWidth < fileTransMessageIconLeft + self.titleLabel.ysf_frameWidth + fileTransMessageSizeTitleRight) {
        self.titleLabel.ysf_frameWidth = self.ysf_frameWidth - fileTransMessageTitleLeft - fileTransMessageSizeTitleRight;
    }
    self.titleLabel.ysf_frameLeft     = fileTransMessageTitleLeft;
    self.titleLabel.ysf_frameTop      = fileTransMessageTitleTop;
    
    self.sizeLabel.ysf_frameRight     = self.ysf_frameWidth - fileTransMessageSizeTitleRight;
    self.sizeLabel.ysf_frameBottom    = self.ysf_frameHeight - fileTransMessageSizeTitleBottom;
    
    self.progressView.ysf_frameTop    = fileTransMessageProgressTop;
    self.progressView.ysf_frameWidth  = self.ysf_frameWidth - fileTransMessageProgressLeft - fileTransMessageProgressRight;
    self.progressView.ysf_frameLeft   = fileTransMessageProgressLeft;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.cornerRadius = 13.0;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.frame = self.bkgView.bounds;
    self.bkgView.layer.mask = maskLayer;
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


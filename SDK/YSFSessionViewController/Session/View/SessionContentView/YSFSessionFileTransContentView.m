//
//  NIMSessionFileTransContentView.m
//  NIM
//
//  Created by chris on 15/4/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionFileTransContentView.h"
#import "YSFMessageModel.h"
#import "UIImage+FileTransfer.h"
#import "NSString+FileTransfer.h"


@interface YSFSessionFileTransContentView()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *sizeLabel;

@property (nonatomic,strong) UILabel *downloadStatusLabel;

@property (nonatomic,strong) UIImageView *fileIconView;

@property (nonatomic, assign) BOOL canTapContent;

@end

@implementation YSFSessionFileTransContentView

- (instancetype)initSessionMessageContentView
{
    self = [super initSessionMessageContentView];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.canTapContent = YES;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.numberOfLines = 2;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.textColor = YSFRGB(0x222222);
    [_titleLabel sizeToFit];
    [self addSubview:_titleLabel];
    
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sizeLabel.numberOfLines = 1;
    _sizeLabel.font = [UIFont systemFontOfSize:12.f];
    _sizeLabel.textAlignment = NSTextAlignmentLeft;
    _sizeLabel.textColor = YSFRGB(0x999999);
    [_sizeLabel sizeToFit];
    [self addSubview:_sizeLabel];
    
    self.downloadStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _downloadStatusLabel.numberOfLines = 1;
    _downloadStatusLabel.font = [UIFont systemFontOfSize:11.f];
    _downloadStatusLabel.textAlignment = NSTextAlignmentLeft;
    _downloadStatusLabel.textColor = YSFRGB(0x999999);
    [_downloadStatusLabel sizeToFit];
    [self addSubview:_downloadStatusLabel];
    
    self.fileIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _fileIconView.layer.cornerRadius = 3.f;
    _fileIconView.contentMode = UIViewContentModeScaleAspectFill;
    _fileIconView.clipsToBounds = YES;
    [self addSubview:_fileIconView];
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)data.message.messageObject;
    _titleLabel.text = fileObject.displayName;
    [_titleLabel sizeToFit];
    _sizeLabel.text = [NSString getFileSizeTextWithFileLength:fileObject.fileLength];
    [_sizeLabel sizeToFit];
    NSTimeInterval todayMilliSecond = [[NSDate date] timeIntervalSince1970] * 1000;     //服务器端返回毫秒
    if (fileObject.expire < todayMilliSecond) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileObject.path]) {
            _downloadStatusLabel.text = @"已下载";
            _canTapContent = YES;
        } else {
            _downloadStatusLabel.text = @"已失效";
            _canTapContent = NO;
        }
    } else {
        _downloadStatusLabel.text = [[NSFileManager defaultManager] fileExistsAtPath:fileObject.path] ? @"已下载" : @"未下载";
        _canTapContent = YES;
    }
    [_downloadStatusLabel sizeToFit];
    
    _fileIconView.image = [UIImage getFileIconWithDefaultIcon:[UIImage ysf_imageInKit:@"icon_file_type_other"] fileName:fileObject.displayName];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.ysf_frameLeft = 15.f;
    self.titleLabel.ysf_frameTop  = 12.f;
    self.titleLabel.ysf_frameWidth = 125.f;
    self.titleLabel.ysf_frameHeight = 45.f;
    
    self.sizeLabel.ysf_frameLeft = self.titleLabel.ysf_frameLeft;
    self.sizeLabel.ysf_frameTop = self.titleLabel.ysf_frameBottom + 1;
    self.sizeLabel.ysf_frameWidth = 56.f;
    self.sizeLabel.ysf_frameHeight = 16.f;
    
    self.downloadStatusLabel.ysf_frameLeft = self.sizeLabel.ysf_frameRight + 35.f;
    self.downloadStatusLabel.ysf_frameTop = self.titleLabel.ysf_frameBottom + 1;
    self.downloadStatusLabel.ysf_frameWidth = 35.f;
    self.downloadStatusLabel.ysf_frameHeight = 15.f;
    
    self.fileIconView.ysf_frameLeft = self.titleLabel.ysf_frameRight + 10;
    self.fileIconView.ysf_frameTop = self.titleLabel.ysf_frameTop;
    self.fileIconView.ysf_frameWidth = 60.f;
    self.fileIconView.ysf_frameHeight = 61.f;
    
}


- (void)onTouchUpInside:(id)sender
{
    if (!_canTapContent) return;
    
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapContent;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
}

#pragma mark - Private
//override
//文件需要显示白色底
- (UIImage *)chatNormalBubbleImage
{
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_filetransfer_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_filetransfer_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

//override
//文件需要显示白色底
- (UIImage *)chatHighlightedBubbleImage
{
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_filetransfer_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_filetransfer_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

@end


//
//  YSFMiniProgramPageContentView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMiniProgramPageContentView.h"
#import "YSFMessageModel.h"
#import "YSFMiniProgramPage.h"
#import "YSFAvatarImageView.h"
#import "QYCustomUIConfig.h"
#import "UIImageView+YSFWebCache.h"

static CGFloat kMiniProgramPageLeftSpace = 8.0f;
static CGFloat kMiniProgramPageTopSpace = 10.0f;
static CGFloat kMiniProgramPageHeadSize = 20.0f;
static CGFloat kMiniProgramPageHeadRightGap = 5.0f;
static CGFloat kMiniProgramPageTitleLeftSpace = 10.0f;
static CGFloat kMiniProgramPageTitleTopSpace = 8.0f;
static CGFloat kMiniProgramPageImageHeight = 166.0f;
static CGFloat kMiniProgramPageBarHeight = 30.0f;
static CGFloat kMiniProgramPageMiniSize = 15.0f;

@interface YSFMiniProgramPageContentView ()

@property (nonatomic, strong) YSFAvatarImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) CALayer *splitLine;
@property (nonatomic, strong) UIImageView *miniImageView;
@property (nonatomic, strong) UILabel *miniLabel;

@end

@implementation YSFMiniProgramPageContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _headImageView = [[YSFAvatarImageView alloc] init];
        _headImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = YSFRGB(0x999999);
        _nameLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:_nameLabel];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = YSFRGB(0x222222);
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = [UIColor clearColor];
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        
        _splitLine = [[CALayer alloc] init];
        _splitLine.backgroundColor = YSFRGB(0xd9d9d9).CGColor;
        [self.layer addSublayer:_splitLine];
        
        _miniImageView = [[UIImageView alloc] initWithImage:[UIImage ysf_imageInKit:@"icon_mini_app"]];
        _miniImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_miniImageView];
        
        _miniLabel = [[UILabel alloc] init];
        _miniLabel.backgroundColor = [UIColor clearColor];
        _miniLabel.textColor = YSFRGB(0x999999);
        _miniLabel.font = [UIFont systemFontOfSize:12.0f];
        _miniLabel.text = @"小程序";
        [self addSubview:_miniLabel];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    UIEdgeInsets inset = self.model.contentViewInsets;
    CGFloat contentWidth = CGRectGetWidth(self.frame) - inset.left - inset.right;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFMiniProgramPage *miniProgram = (YSFMiniProgramPage *)object.attachment;
    //head image
    UIImage *placeHolder = [UIImage ysf_imageInKit:@"icon_service_avatar"];
    [_headImageView ysf_setImageWithURL:[NSURL URLWithString:miniProgram.headImgURL] placeholderImage:placeHolder];
    _headImageView.frame = CGRectMake(inset.left + kMiniProgramPageLeftSpace , kMiniProgramPageTopSpace, kMiniProgramPageHeadSize, kMiniProgramPageHeadSize);
    //name label
    _nameLabel.text = miniProgram.name;
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + kMiniProgramPageHeadRightGap,
                                  kMiniProgramPageTopSpace,
                                  contentWidth - CGRectGetMaxX(_headImageView.frame) - kMiniProgramPageHeadRightGap,
                                  kMiniProgramPageHeadSize);
    //title label
    _titleLabel.text = miniProgram.title;
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    CGFloat fontSize = self.model.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _titleLabel.ysf_frameWidth = contentWidth - 2 * kMiniProgramPageTitleLeftSpace;
    [_titleLabel sizeToFit];
    _titleLabel.ysf_frameLeft = inset.left + kMiniProgramPageTitleLeftSpace;
    _titleLabel.ysf_frameTop = CGRectGetMaxY(_headImageView.frame) + kMiniProgramPageTitleTopSpace;
    //cover image
    CGFloat coverW = contentWidth - 2 * kMiniProgramPageTitleLeftSpace;
    CGFloat coverH = kMiniProgramPageImageHeight;
    _coverImageView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),
                                       CGRectGetMaxY(_titleLabel.frame) + kMiniProgramPageTitleTopSpace,
                                       coverW,
                                       coverH);
    
    _coverImageView.contentMode = UIViewContentModeScaleToFill;
    UIImage *loadingImage = [UIImage ysf_imageInKit:@"icon_image_loading_default"];
    __weak typeof(self) weakSelf = self;
    [_coverImageView ysf_setImageWithURL:[NSURL URLWithString:miniProgram.coverImgURL]
                        placeholderImage:loadingImage
                               completed:^(UIImage * image, NSError * error, YSFImageCacheType cacheType, NSURL * imageURL) {
                                   if (error) {
                                       UIImage *failImage = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                       weakSelf.coverImageView.image = failImage;
                                   } else if (image) {
                                       CGFloat scaleH = (coverH / coverW) * image.size.width;
                                       weakSelf.coverImageView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width, scaleH))];
                                   }
                               }];
    //split line
    _splitLine.frame = CGRectMake(inset.left,
                                  CGRectGetMaxY(_coverImageView.frame) + kMiniProgramPageTitleTopSpace,
                                  contentWidth,
                                  1. / [UIScreen mainScreen].scale);
    //mini image
    _miniImageView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),
                                      CGRectGetMinY(_splitLine.frame) + (kMiniProgramPageBarHeight - kMiniProgramPageMiniSize) / 2,
                                      kMiniProgramPageMiniSize,
                                      kMiniProgramPageMiniSize);
    //mini label
    _miniLabel.frame = CGRectMake(CGRectGetMaxX(_miniImageView.frame) + kMiniProgramPageHeadRightGap,
                                  CGRectGetMinY(_miniImageView.frame),
                                  contentWidth - CGRectGetMaxX(_miniImageView.frame) - kMiniProgramPageHeadRightGap,
                                  kMiniProgramPageMiniSize);
}

#pragma mark - override
- (UIImage *)chatNormalBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_filetransfer_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                                                                                               resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_filetransfer_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                                                                                                resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

- (UIImage *)chatHighlightedBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_filetransfer_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                                                                                                resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_filetransfer_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                                                                                                 resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

@end

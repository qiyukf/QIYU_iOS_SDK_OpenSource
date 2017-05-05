//
//  NIMSessionMessageContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionMessageContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"

@implementation YSFSessionMessageContentView

- (instancetype)initSessionMessageContentView
{
    CGSize defaultBubbleSize = CGSizeMake(60, 35);
    if (self = [self initWithFrame:CGRectMake(0, 0, defaultBubbleSize.width, defaultBubbleSize.height)]) {
        self.opaque = YES;
        [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,defaultBubbleSize.width,defaultBubbleSize.height)];
        _bubbleImageView.opaque = YES;
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bubbleImageView];
    }
    return self;
}

- (void)refresh:(YSFMessageModel*)data{
    _model = data;
    CGSize size = [self bubbleViewSize:data];
    self.bounds = CGRectMake(0, 0, size.width, size.height);
    switch (self.bubbleType) {
        case YSFKitBubbleTypeChat:
        {
            [_bubbleImageView setImage:[self chatNormalBubbleImage]];
            [_bubbleImageView setHighlightedImage:[self chatHighlightedBubbleImage]];
        }
            break;
        case YSFKitBubbleTypeNotify:
            [_bubbleImageView setImage:[self notifyBubbleImage]];
        default:
            break;
    }
    _bubbleImageView.frame = self.bounds;
    [self setNeedsLayout];
}


- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void)updateProgress:(float)progress
{
    
}

- (void)onTouchDown:(id)sender
{
    
}

- (void)onTouchUpInside:(id)sender
{
    
}

- (void)onTouchUpOutside:(id)sender{
    
}


#pragma mark - Private
- (UIImage *)chatNormalBubbleImage
{
    QYCustomUIConfig *customUIConfig = [QYCustomUIConfig sharedInstance];
    return self.model.message.isOutgoingMsg ?
    customUIConfig.customerMessageBubbleNormalImage: customUIConfig.serviceMessageBubbleNormalImage;
}

- (UIImage *)chatHighlightedBubbleImage
{
    QYCustomUIConfig *customUIConfig = [QYCustomUIConfig sharedInstance];
    return self.model.message.isOutgoingMsg ?
    customUIConfig.customerMessageBubblePressedImage: customUIConfig.serviceMessageBubblePressedImage;
}


- (UIImage *)notifyBubbleImage
{
    return [[UIImage ysf_imageInKit:@"icon_tip_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10,10,10,10) resizingMode:UIImageResizingModeStretch];
}

- (CGSize)bubbleViewSize:(YSFMessageModel *)model
{
    CGSize bubbleSize;
    id<YSFCellLayoutConfig> config = model.layoutConfig;
    CGSize contentSize  = model.contentSize;
    UIEdgeInsets insets = [config contentViewInsets:model];
    bubbleSize.width  = contentSize.width + insets.left + insets.right;
    bubbleSize.height = contentSize.height + insets.top + insets.bottom;
    return bubbleSize;
}


- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_bubbleImageView setHighlighted:highlighted];
}

@end

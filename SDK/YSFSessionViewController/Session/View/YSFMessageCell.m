//
//  NIMMessageCell.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageCell.h"
#import "YSFMessageModel.h"
#import "YSFAvatarImageView.h"
#import "YSFBadgeView.h"
#import "YSFSessionMessageContentView.h"
#import "YSFKitUtil.h"
#import "YSFSessionAudioContentView.h"
#import "YSFDefaultValueMaker.h"
#import "YSFAttributedLabel.h"
#import "YSFSessionUnknowContentView.h"
#import "KFAudioToTextHandler.h"


@interface YSFMessageCell()<YSFPlayAudioUIDelegate,YSFMessageContentViewDelegate>{
    UILongPressGestureRecognizer *_longPressGesture;
}

@end

@implementation YSFMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        //
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self makeComponents];
        [self makeGesture];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:_longPressGesture];
}

- (void)makeComponents
{
    //retyrBtn
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_retryButton setImage:[UIImage ysf_imageInKit:@"icon_message_cell_error"] forState:UIControlStateNormal];
    [_retryButton setImage:[UIImage ysf_imageInKit:@"icon_message_cell_error"] forState:UIControlStateHighlighted];
    [_retryButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_retryButton addTarget:self action:@selector(onRetryMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_retryButton];
    
    //audioPlayedIcon
    _audioPlayedIcon = [YSFBadgeView viewWithBadgeTip:@""];
    [self.contentView addSubview:_audioPlayedIcon];
    
    //traningActivityIndicator
    _traningActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [_traningActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_traningActivityIndicator];
    
    //headerView
    _headImageView = [[YSFAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_headImageView addTarget:self action:@selector(onTapAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headImageView];
    
    //nicknamel
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.opaque = YES;
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
    [_nameLabel setTextColor:[UIColor darkGrayColor]];
    [_nameLabel setHidden:YES];
    [self.contentView addSubview:_nameLabel];
    
}

- (void)makeGesture{
    _longPressGesture= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
    [self addGestureRecognizer:_longPressGesture];
}

- (void)refreshData:(YSFMessageModel *)data{
    self.model = data;
    if ([self checkData]) {
        [self refresh];
    }
}

- (BOOL)checkData{
    return [self.model isKindOfClass:[YSFMessageModel class]];
}


- (void)setModel:(YSFMessageModel *)model{
    _model = model;
}

- (void)refresh{
    [self addContentViewIfNotExist];
    
    if ([self needShowAvatar])
    {
        NSString *fromYxId = self.model.message.from;
        BOOL customerOrService = YES;
        NSString *account = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
        if (self.model.message.session.sessionType == YSF_NIMSessionTypeYSF &&
            ![account isEqualToString:fromYxId])        {
            customerOrService = NO;
        }
        else
        {
            customerOrService = YES;
        }
        [_headImageView setAvatarBySession:customerOrService message: self.model.message];
    }
    
    if([self needShowNickName])
    {
        NSString *nick = [YSFKitUtil showNick:self.model.message.from inSession:self.model.message.session];
        [_nameLabel setText:nick];
    }
    [_nameLabel setHidden:![self needShowNickName]];
    [_bubbleView refresh:self.model];
    
    BOOL isActivityIndicatorHidden = [self activityIndicatorHidden];
    if (isActivityIndicatorHidden) {
        [_traningActivityIndicator stopAnimating];
    } else
    {
        [_traningActivityIndicator startAnimating];
    }
    [_traningActivityIndicator setHidden:isActivityIndicatorHidden];
    [_retryButton setHidden:[self retryButtonHidden]];
    [_audioPlayedIcon setHidden:[self unreadHidden]];
    [self setNeedsLayout];
}

- (void)addContentViewIfNotExist
{
    if (_bubbleView == nil)
    {
        id<YSFCellLayoutConfig> config = self.model.layoutConfig;
        NSString *contentStr = [config cellContent:self.model];
        if (!contentStr.length) {
            //针对上层实现了cellContent:接口，但是没有覆盖全的情况
            YSFCellLayoutDefaultConfig *config = [YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig;
            contentStr = [config cellContent:self.model];
        }
        Class clazz = NSClassFromString(contentStr);
        YSFSessionMessageContentView *contentView =  [[clazz alloc] initSessionMessageContentView];
        if (!contentView) {
            //还是拿不到那就只好unsupported了
            contentView = [self unSupportContentView];
        }
        _bubbleView = contentView;
        _bubbleView.delegate = self;
        YSF_NIMMessageType messageType = self.model.message.messageType;
        if (messageType == YSF_NIMMessageTypeAudio) {
            ((YSFSessionAudioContentView *)_bubbleView).audioUIDelegate = self;
        }
        
        [self.contentView addSubview:_bubbleView];
    }
}

- (YSFSessionMessageContentView *)unSupportContentView{
    return [[YSFSessionUnknowContentView alloc] initSessionMessageContentView];
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    //兼容ipad
    if ((self.bubbleView.frame.size.width > self.frame.size.width) && iPadDevice) {
        self.bubbleView.frame = CGRectMake(_bubbleView.frame.origin.x, _bubbleView.frame.origin.y, self.frame.size.width, _bubbleView.frame.size.height);
        [self.model reCalculateContent:self.frame.size.width];
        [_bubbleView refresh:self.model];
    }
    
    [self layoutAvatar];
    [self layoutNameLabel];
    [self layoutBubbleView];
    [self layoutRetryButton];
    [self layoutAudioPlayedIcon];
    [self layoutActivityIndicator];
}

- (void)layoutAvatar
{
    BOOL needShow = [self needShowAvatar];
    _headImageView.hidden = !needShow;
    if (needShow) {
        _headImageView.frame = [self avatarViewRect];
    }
}

- (void)layoutNameLabel
{
    if ([self needShowNickName]) {
        CGFloat otherBubbleOriginX  = 55.f;
        CGFloat otherNickNameHeight = 20.f;
        _nameLabel.frame = CGRectMake(otherBubbleOriginX + 2, -3,
                                      200, otherNickNameHeight);
    }
}

- (void)layoutBubbleView
{
    UIEdgeInsets contentInsets = self.model.bubbleViewInsets;
    if (self.model.message.isOutgoingMsg) {
        CGFloat protraitRightToBubble = 5.f;
        CGFloat right = self.model.shouldShowAvatar? CGRectGetMinX(self.headImageView.frame)  - protraitRightToBubble : self.ysf_frameWidth;
        contentInsets.left = right - CGRectGetWidth(self.bubbleView.bounds);
    }
    else {
        if (!self.model.shouldShowAvatar) {
            CGFloat right = CGRectGetMinX(self.headImageView.frame);
            contentInsets.left = -right;
        }
    }
    _bubbleView.ysf_frameLeft = contentInsets.left;
    _bubbleView.ysf_frameTop  = contentInsets.top;
}

- (void)layoutActivityIndicator
{
    if (_traningActivityIndicator.isAnimating) {
        CGFloat centerX = 0;
        if (self.model.message.isOutgoingMsg) {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_traningActivityIndicator.bounds)/2;;
        } else
        {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] +  CGRectGetWidth(_traningActivityIndicator.bounds)/2;
        }
        self.traningActivityIndicator.center = CGPointMake(centerX,
                                                           _bubbleView.center.y);
    }
}

- (void)layoutRetryButton
{
    if (!_retryButton.isHidden) {
        CGFloat centerX = 0;
        if (!self.model.message.isOutgoingMsg) {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] +CGRectGetWidth(_retryButton.bounds)/2;
        } else
        {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_retryButton.bounds)/2;
        }
        
        _retryButton.center = CGPointMake(centerX, _bubbleView.center.y);
    }
}

- (void)layoutAudioPlayedIcon{
    if (!_audioPlayedIcon.hidden) {
        CGFloat padding = [self audioPlayedIconBubblePadding];
        if (!self.model.message.isOutgoingMsg) {
            _audioPlayedIcon.ysf_frameLeft = _bubbleView.ysf_frameRight + padding;
        } else
        {
            _audioPlayedIcon.ysf_frameRight = _bubbleView.ysf_frameLeft - padding;
        }
        _audioPlayedIcon.ysf_frameTop = _bubbleView.ysf_frameTop;
    }
}

#pragma mark - NIMMessageContentViewDelegate
- (void)onCatchEvent:(YSFKitEvent *)event{
    if ([self.messageDelegate respondsToSelector:@selector(onTapCell:)]) {
        [self.messageDelegate onTapCell:event];
    }
}

#pragma mark - Action
- (void)onRetryMessage:(id)sender
{
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(onRetryMessage:)]) {
        [_messageDelegate onRetryMessage:self.model.message];
    }
}

- (void)longGesturePress:(UIGestureRecognizer*)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        if (state == UIGestureRecognizerStateBegan)
        {
            if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(onLongPressCell:inView:)]) {
                [_messageDelegate onLongPressCell:self.model.message
                                           inView:_bubbleView];
            }

        }
    }
}


#pragma mark - NIMPlayAudioUIDelegate
- (void)startPlayingAudioUI
{
    //更新DB
    YSF_NIMMessage * message = self.model.message;
    if (!message.isPlayed) {
        message.isPlayed  = YES;
        [self refreshData:self.model];
    }
}



#pragma mark - Private
- (CGRect)avatarViewRect
{
    CGFloat cellWidth = self.bounds.size.width;
    CGFloat cellPaddingToProtrait = 8.f;
    CGFloat protraitImageWidth    = 40;//头像宽
    CGFloat selfProtraitOriginX   = (cellWidth - cellPaddingToProtrait - protraitImageWidth);
    return self.model.message.isOutgoingMsg ? CGRectMake(selfProtraitOriginX, 3,
                                                                       protraitImageWidth,
                                                                       protraitImageWidth) : CGRectMake(cellPaddingToProtrait, 3,                      protraitImageWidth, protraitImageWidth);
}

- (BOOL)needShowAvatar
{
    return self.model.shouldShowAvatar;
}

- (BOOL)needShowNickName
{
    return self.model.shouldShowNickName;
}


- (BOOL)retryButtonHidden
{
    if (!self.model.message.isReceivedMsg) {
        if (self.model.message.deliveryState == YSF_NIMMessageDeliveryStateFailed) {
            if ([[KFAudioToTextHandler sharedInstance] audioInTransfering:self.model.message.messageId]) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            return YES;
        }
    }
    else
    {
        return self.model.message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateFailed;
    }
}

- (CGFloat)retryButtonBubblePadding {
    BOOL isFromMe = self.model.message.isOutgoingMsg;
    if (self.model.message.messageType == YSF_NIMMessageTypeAudio) {
        return isFromMe ? 15 : 13;
    }
    return isFromMe ? 8 : 10;
}

- (BOOL)activityIndicatorHidden
{
    if (!self.model.message.isReceivedMsg) {
        YSF_NIMMessageDeliveryState state = self.model.message.deliveryState;
        if (state != YSF_NIMMessageDeliveryStateDelivering) {
            return ![[KFAudioToTextHandler sharedInstance] audioInTransfering:self.model.message.messageId];
        }
        return NO;
    }
    else
    {
        return self.model.message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateDownloading;
    }
}


- (BOOL)unreadHidden {
    if (self.model.message.messageType == YSF_NIMMessageTypeAudio) { //音频
        BOOL showIcon = YES;
        return (!showIcon || self.model.message.isOutgoingMsg || [self.model.message isPlayed]);
    }
    return YES;
}

- (CGFloat)audioPlayedIconBubblePadding{
    return 10;
}



- (void)onTapAvatar:(id)sender{
    if ([_messageDelegate respondsToSelector:@selector(onTapAvatar:)]) {
        [_messageDelegate onTapAvatar:self.model.message.from];
    }
}

@end

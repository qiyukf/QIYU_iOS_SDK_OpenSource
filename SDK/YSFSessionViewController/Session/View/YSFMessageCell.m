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
#import "YSFSessionUnknowContentView.h"
#import "KFAudioToTextHandler.h"
#import "YSFKit.h"
#import "YSFApiDefines.h"
#import "YSFBotForm.h"
#import "YSF_NIMMessage+YSF.h"

@interface YSFMessageCell() <YSFPlayAudioUIDelegate,YSFMessageContentViewDelegate> {
    UILongPressGestureRecognizer *_longPressGesture;
}

@end


@implementation YSFMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        [self makeComponents];
        [self makeGesture];
    }
    return self;
}

- (void)dealloc {
    [self removeGestureRecognizer:_longPressGesture];
}

- (void)makeComponents {
    //headerView
    _headImageView = [[YSFAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_headImageView addTarget:self action:@selector(onTapAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headImageView];
    //vipLevel
    _vipLevel = [[UIImageView alloc] initWithFrame:CGRectMake(36, 30, 40, 40)];
    [self.contentView addSubview:_vipLevel];
    //loadingIndicator
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [_loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_loadingIndicator];
    //audioPlayedIcon
    _audioPlayedIcon = [YSFBadgeView viewWithBadgeTip:@""];
    [self.contentView addSubview:_audioPlayedIcon];
    //nicknamel
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.opaque = YES;
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
    [_nameLabel setTextColor:[UIColor darkGrayColor]];
    [_nameLabel setHidden:YES];
    [self.contentView addSubview:_nameLabel];
    //trashWordsTip
    _trashWordsTip = [UILabel new];
    _trashWordsTip.numberOfLines = 0;
    _trashWordsTip.lineBreakMode = NSLineBreakByCharWrapping;
    _trashWordsTip.font = [UIFont systemFontOfSize:12.f];
    _trashWordsTip.backgroundColor = [UIColor clearColor];
    _trashWordsTip.textColor = YSFRGB(0xe64340);
    [self.contentView addSubview:_trashWordsTip];
    //retyrBtn
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_retryButton setFrame:CGRectMake(0, 0, 18, 18)];
    [_retryButton addTarget:self action:@selector(onRetryMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_retryButton];
    //submitForm
    _submitForm = [[UIButton alloc] init];
    [_submitForm addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];
    _submitForm.titleLabel.font = [UIFont systemFontOfSize:14];
    _submitForm.backgroundColor = [UIColor whiteColor];
    _submitForm.layer.borderColor = YSFRGB(0xd9d9d9).CGColor;
    _submitForm.layer.cornerRadius = 16.5;
    _submitForm.layer.borderWidth = 0.5;
    [_submitForm setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    [_submitForm setTitle:@"填写表单" forState:UIControlStateNormal];
    [self.contentView addSubview:_submitForm];
}

- (void)makeGesture {
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
    [self addGestureRecognizer:_longPressGesture];
}

#pragma mark - data model
- (void)setModel:(YSFMessageModel *)model {
    _model = model;
}

- (void)refreshData:(YSFMessageModel *)data {
    self.model = data;
    if ([self checkData]) {
        [self refresh];
    }
}

- (BOOL)checkData {
    return [self.model isKindOfClass:[YSFMessageModel class]];
}

#pragma mark - refresh
- (void)refresh {
    [self addContentViewIfNotExist];
    _vipLevel.hidden = YES;
    _trashWordsTip.hidden = YES;
    _submitForm.hidden = YES;
    //设置头像
    if ([self needShowAvatar]) {
        NSString *fromYxId = self.model.message.from;
        BOOL customerOrService = YES;
        NSString *account = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
        if (self.model.message.session.sessionType == YSF_NIMSessionTypeYSF
            && ![account isEqualToString:fromYxId]) {
            //客服端
            customerOrService = NO;
            YSFSessionUserInfo *sessionUserInfo = [[YSFKit sharedKit] infoByService:self.model.message];
            NSString *vipLevel = [NSString stringWithFormat:@"v%ld", (long)sessionUserInfo.vipLevel];
            _vipLevel.image = [UIImage imageNamed:vipLevel];
            [_vipLevel sizeToFit];
            _vipLevel.hidden = NO;
        } else {
            //访客端
            customerOrService = YES;
        }
        [_headImageView setAvatarBySession:customerOrService message:self.model.message];
    }
    //设置昵称（目前均不显示）
    if ([self needShowNickName]) {
        NSString *nick = [YSFKitUtil showNick:self.model.message.from inSession:self.model.message.session];
        [_nameLabel setText:nick];
    }
    [_nameLabel setHidden:![self needShowNickName]];
    // ** 刷新内容区域 **
    [_bubbleView refresh:self.model];
    //loading动画显示
    BOOL isloadingHidden = [self loadingIndicatorHidden];
    if (isloadingHidden) {
        [_loadingIndicator stopAnimating];
    } else {
        [_loadingIndicator startAnimating];
    }
    [_loadingIndicator setHidden:isloadingHidden];
    //音频消息未读红点显示
    [_audioPlayedIcon setHidden:[self unreadHidden]];
    //重试按钮 & 违禁词提示
    [_retryButton setHidden:[self retryButtonHidden]];
    _retryButton.userInteractionEnabled = YES;
    [_retryButton setImage:[UIImage ysf_imageInKit:@"icon_message_cell_error"] forState:UIControlStateNormal];
    if (self.model.message.isOutgoingMsg && [self.model.message hasTrashWords]) {
        [_retryButton setImage:[UIImage ysf_imageInKit:@"icon_file_transfer_cancel"] forState:UIControlStateNormal];
        _retryButton.hidden = NO;
        _retryButton.userInteractionEnabled = NO;
        _trashWordsTip.hidden = NO;
    }
    _trashWordsTip.text = [self.model.message getTrashWordsTip];
    if (_trashWordsTip.text.length == 0) {
        NSString *tip =  [self.model.message getMiniAppTimeTip];
        if (tip.length > 0) {
            [_retryButton setImage:[UIImage ysf_imageInKit:@"icon_file_transfer_cancel"] forState:UIControlStateNormal];
            _retryButton.hidden = NO;
            _retryButton.userInteractionEnabled = NO;
            _trashWordsTip.hidden = NO;
            _trashWordsTip.text = tip;
        }
    }
    //表单提交按钮
    if (self.model.message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = self.model.message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFBotForm class]]) {
            _submitForm.hidden = ((YSFBotForm *)customObject.attachment).submitted;
        }
    }
    //扩展视图
    if ([self needShowExtraView] && !_extraView) {
        [self makeupExtraView];
    }
    [_extraView configWithMsgModel:self.model];
    
    [self setNeedsLayout];
}

- (void)addContentViewIfNotExist {
    if (_bubbleView == nil) {
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

- (YSFSessionMessageContentView *)unSupportContentView {
    return [[YSFSessionUnknowContentView alloc] initSessionMessageContentView];
}

- (void)makeupExtraView {
    id<YSFExtraCellLayoutConfig> extraCellConfig = self.model.extraLayoutConfig;
    if (extraCellConfig.extraViewClass && [extraCellConfig.extraViewClass conformsToProtocol:@protocol(YSFExtraViewParamConfig)]) {
        _extraView = [[extraCellConfig.extraViewClass alloc] init];
        _extraView.delegate = self;
        [self.contentView addSubview:_extraView];
    }
}

#pragma mark - layout
- (void)layoutSubviews {
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
    [self layoutExtraView];
    
    _trashWordsTip.frame = CGRectMake(0, _bubbleView.ysf_frameBottom + 10, self.ysf_frameWidth - 112, 0);
    [_trashWordsTip sizeToFit];
    _trashWordsTip.ysf_frameRight = _bubbleView.ysf_frameRight - 5;
    
    _submitForm.ysf_frameWidth = 93;
    _submitForm.ysf_frameTop = _bubbleView.ysf_frameBottom + 10;
    _submitForm.ysf_frameLeft = _bubbleView.ysf_frameLeft + 5;
    _submitForm.ysf_frameHeight = 33;
}

- (void)layoutAvatar {
    BOOL needShow = [self needShowAvatar];
    _headImageView.hidden = !needShow;
    if (needShow) {
        _headImageView.frame = [self headImageViewRect];
    }
}

- (CGRect)headImageViewRect {
    CGFloat cellWidth = self.bounds.size.width;
    if (@available(iOS 11, *)) {
        cellWidth -= (self.safeAreaInsets.left + self.safeAreaInsets.right);
    }
    if (self.model.message.isOutgoingMsg) {
        //发送消息
        return CGRectMake(cellWidth - kHeadHorizontalMargin - kHeadImageSize, kHeadVerticalMargin, kHeadImageSize, kHeadImageSize);
    } else {
        //接收消息
        return CGRectMake(kHeadHorizontalMargin, kHeadVerticalMargin, kHeadImageSize, kHeadImageSize);
    }
}

- (void)layoutNameLabel {
    if ([self needShowNickName]) {
        _nameLabel.frame = CGRectMake(55 + 2, -3, 200, 20);
    }
}

- (void)layoutBubbleView {
    UIEdgeInsets contentInsets = self.model.bubbleViewInsets;
    if (self.model.message.isOutgoingMsg) {
        //发送消息
        CGFloat right = self.model.shouldShowAvatar ? CGRectGetMinX(self.headImageView.frame) : self.ysf_frameWidth;
        right -= self.model.avatarBubbleSpace;
        contentInsets.left = right - CGRectGetWidth(self.bubbleView.bounds);
    } else {
        //接收消息
        if (!self.model.shouldShowAvatar) {
            contentInsets.left = self.model.avatarBubbleSpace;
        }
    }
    _bubbleView.ysf_frameLeft = contentInsets.left;
    _bubbleView.ysf_frameTop  = contentInsets.top;
}

- (void)layoutActivityIndicator {
    if (_loadingIndicator.isAnimating) {
        CGFloat centerX = 0;
        if (self.model.message.isOutgoingMsg) {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_loadingIndicator.bounds) / 2;;
        } else {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] + CGRectGetWidth(_loadingIndicator.bounds) / 2;
        }
        self.loadingIndicator.center = CGPointMake(centerX, _bubbleView.center.y);
    }
}

- (void)layoutRetryButton {
    if (!_retryButton.isHidden) {
        CGFloat centerX = 0;
        if (!self.model.message.isOutgoingMsg) {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] + CGRectGetWidth(_retryButton.bounds) / 2;
        } else {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_retryButton.bounds) / 2;
        }
        _retryButton.center = CGPointMake(centerX, _bubbleView.center.y);
    }
}

- (void)layoutAudioPlayedIcon {
    if (!_audioPlayedIcon.hidden) {
        CGFloat padding = [self audioPlayedIconBubblePadding];
        if (!self.model.message.isOutgoingMsg) {
            _audioPlayedIcon.ysf_frameLeft = _bubbleView.ysf_frameRight + padding;
        } else {
            _audioPlayedIcon.ysf_frameRight = _bubbleView.ysf_frameLeft - padding;
        }
        _audioPlayedIcon.ysf_frameTop = _bubbleView.ysf_frameTop;
    }
}

- (void)layoutExtraView {
    CGFloat extraContentRealW = self.model.extraViewSize.width + self.model.extraViewInsets.left + self.model.extraViewInsets.right;
    BOOL showExtra = [self needShowExtraView] && (self.bubbleView.ysf_frameRight >= extraContentRealW);
    self.extraView.hidden = !showExtra;
    
    self.extraView.ysf_frameSize = self.model.extraViewSize;
    self.extraView.ysf_frameLeft = self.bubbleView.ysf_frameRight + self.model.extraViewInsets.left;
    self.extraView.ysf_frameBottom = self.bubbleView.ysf_frameBottom + self.model.extraViewInsets.bottom;
}

- (BOOL)needShowAvatar {
    return self.model.shouldShowAvatar;
}

- (BOOL)needShowNickName {
    return self.model.shouldShowNickName;
}

- (BOOL)needShowExtraView {
    return self.model.shouldShowExtraView;
}

- (BOOL)retryButtonHidden {
    if (!self.model.message.isReceivedMsg) {
        //发送消息
        if (self.model.message.messageType == YSF_NIMMessageTypeVideo) {
            if (self.model.message.deliveryState == YSF_NIMMessageDeliveryStateFailed) {
                return NO;
            }
            return YES;
        }
        if (self.model.message.deliveryState == YSF_NIMMessageDeliveryStateFailed) {
            if ([[KFAudioToTextHandler sharedInstance] audioInTransfering:self.model.message.messageId]) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        //接收消息
        return (self.model.message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateFailed);
    }
}

- (CGFloat)retryButtonBubblePadding {
    if (self.model.message.messageType == YSF_NIMMessageTypeAudio) {
        return self.model.message.isOutgoingMsg ? 15 : 13;
    }
    return self.model.message.isOutgoingMsg ? 8 : 10;
}

- (BOOL)loadingIndicatorHidden {
    if (!self.model.message.isReceivedMsg) {
        //发送消息
        //对于视频消息，不显示消息左侧的indicator，因视频消息内部已显示loading动画
        if (self.model.message.messageType == YSF_NIMMessageTypeVideo) {
            return YES;
        }
        YSF_NIMMessageDeliveryState state = self.model.message.deliveryState;
        if (state != YSF_NIMMessageDeliveryStateDelivering) {
            return ![[KFAudioToTextHandler sharedInstance] audioInTransfering:self.model.message.messageId];
        } else {
            return NO;
        }
    } else {
        //接收消息
        return (self.model.message.attachmentDownloadState != YSF_NIMMessageAttachmentDownloadStateDownloading);
    }
}

- (BOOL)unreadHidden {
    //音频
    if (self.model.message.messageType == YSF_NIMMessageTypeAudio) {
        BOOL showIcon = YES;
        return (!showIcon || self.model.message.isOutgoingMsg || [self.model.message isPlayed]);
    }
    return YES;
}

- (CGFloat)audioPlayedIconBubblePadding {
    return 10;
}

#pragma mark - Action
- (void)onTapAvatar:(id)sender {
    if ([_messageDelegate respondsToSelector:@selector(onTapAvatar:)]) {
        [_messageDelegate onTapAvatar:self.model.message.from];
    }
}

- (void)onRetryMessage:(id)sender {
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(onRetryMessage:)]) {
        [_messageDelegate onRetryMessage:self.model.message];
    }
}

- (void)longGesturePress:(UIGestureRecognizer*)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (state == UIGestureRecognizerStateBegan) {
            if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(onLongPressCell:inView:)]) {
                [_messageDelegate onLongPressCell:self.model.message inView:_bubbleView];
            }
        }
    }
}

#pragma mark - Tap BotForm
- (void)onClickAction:(id)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapFillInBotForm;
    event.message = self.model.message;
    [self onCatchEvent:event];
}

- (void)onCatchEvent:(YSFKitEvent *)event {
    if ([self.messageDelegate respondsToSelector:@selector(onTapCell:)]) {
        [self.messageDelegate onTapCell:event];
    }
}

#pragma mark - NIMPlayAudioUIDelegate
- (void)startPlayingAudioUI {
    //更新DB
    YSF_NIMMessage * message = self.model.message;
    if (!message.isPlayed) {
        message.isPlayed  = YES;
        [self refreshData:self.model];
    }
}

@end

//
//  YSFCustomMessageCell.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "YSFCustomMessageCell.h"
#import "QYCustomUIConfig.h"
#import "QYCustomSDK.h"
#import "QYCustomMessage_Private.h"
#import "QYCustomModel_Private.h"
#import "QYCustomContentView_Private.h"
#import "QYCustomMessageProtocol.h"
#import "YSFCustomMessageManager.h"
#import "YSFAvatarImageView.h"

static CGFloat kAvatarImageSize = 40.0f;
static CGFloat kAvatarHorizontalMargin = 8.0f;
static CGFloat kAvatarVerticalMargin = 3.0f;


@interface YSFCustomMessageCell ()

@property (nonatomic, strong) YSFAvatarImageView *avatarView;
@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) QYCustomContentView *customContentView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation YSFCustomMessageCell
- (void)dealloc {
    [self removeGestureRecognizer:_longPressGesture];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturePress:)];
        [self addGestureRecognizer:_longPressGesture];
    }
    return self;
}

- (YSFAvatarImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[YSFAvatarImageView alloc] initWithFrame:CGRectZero];
        [_avatarView addTarget:self action:@selector(onTapAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_avatarView];
    }
    return _avatarView;
}

- (UIImageView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bubbleView.userInteractionEnabled = YES;
        [self.contentView addSubview:_bubbleView];
    }
    return _bubbleView;
}

- (QYCustomContentView *)customContentView {
    if (!_customContentView) {
        NSString *contentClsName = [[YSFCustomMessageManager sharedManager] contentClassNameForMessageClass:[self.model.message class]];
        if (contentClsName.length) {
            Class contentCls = NSClassFromString(contentClsName);
            if (contentCls) {
                _customContentView = [[contentCls alloc] initCustomContentView];
            }
        }
        if (!_customContentView) {
            _customContentView = [[QYCustomContentView alloc] initCustomContentView];
        }
        if (self.model.shouldShowBubble) {
            [self.bubbleView addSubview:_customContentView];
            [self.bubbleView bringSubviewToFront:_customContentView];
        } else {
            [self.contentView addSubview:_customContentView];
            [self.contentView bringSubviewToFront:_customContentView];
        }
        _customContentView.userInteractionEnabled = YES;
    }
    return _customContentView;
}

- (void)setMessageDelegate:(id<QYCustomContentViewDelegate>)messageDelegate {
    _messageDelegate = messageDelegate;
    if ([self.customContentView respondsToSelector:@selector(setDelegate:)]) {
        [self.customContentView setDelegate:_messageDelegate];
    }
}

#pragma mark - refresh data
- (void)refreshData:(QYCustomModel *)model {
    self.model = model;
    if ([model isKindOfClass:[QYCustomModel class]]) {
        [self refreshLayout];
    }
}

#pragma mark - refresh layout
- (void)refreshLayout {
    BOOL showAvatar = self.model.shouldShowAvatar;
    BOOL showBubble = self.model.shouldShowBubble;
    
    self.avatarView.hidden = !showAvatar;
    self.bubbleView.hidden = !showBubble;
    self.customContentView.hidden = NO;
    
    if (showAvatar) {
        if (self.model.message.sourceType == QYCustomMessageSourceTypeNone) {
            self.avatarView.hidden = YES;
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
            //访客头像
            [self.avatarView setAvatarBySession:YES message:self.model.ysfMessage];
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
            //客服头像
            [self.avatarView setAvatarBySession:NO message:self.model.ysfMessage];
        }
    }
    if (showBubble) {
        if (self.model.message.sourceType == QYCustomMessageSourceTypeNone) {
            self.bubbleView.hidden = YES;
        } else {
            [_bubbleView setImage:[self normalBubbleImage]];
            [_bubbleView setHighlightedImage:[self highlightedBubbleImage]];
        }
    }
    
    [self refreshSubviews];
    
    [self.customContentView refreshData:self.model];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshSubviews];
}

- (void)refreshSubviews {
    CGFloat cellWidth = self.contentView.bounds.size.width;
    CGFloat cellHeight = self.contentView.bounds.size.height;
    BOOL showAvatar = self.model.shouldShowAvatar;
    BOOL showBubble = self.model.shouldShowBubble;
    
    self.avatarView.hidden = !showAvatar;
    self.bubbleView.hidden = !showBubble;
    
    [self resetCustomContentView];
    self.customContentView.hidden = NO;
    
    if (showAvatar) {
        if (self.model.message.sourceType == QYCustomMessageSourceTypeNone) {
            self.avatarView.hidden = YES;
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
            //访客头像
            self.avatarView.frame = CGRectMake(cellWidth - kAvatarHorizontalMargin - kAvatarImageSize,
                                               kAvatarVerticalMargin,
                                               kAvatarImageSize,
                                               kAvatarImageSize);
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
            //客服头像
            self.avatarView.frame = CGRectMake(kAvatarHorizontalMargin,
                                               kAvatarVerticalMargin,
                                               kAvatarImageSize,
                                               kAvatarImageSize);
        }
    }
    if (showBubble) {
        if (self.model.message.sourceType == QYCustomMessageSourceTypeNone) {
            self.bubbleView.hidden = YES;
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
            //访客气泡
            CGSize size = [self bubbleViewSize:self.model maxWidth:(cellWidth - kBubbleViewMinMargin)];
            CGFloat left = 0;
            if (showAvatar) {
                left = CGRectGetMinX(self.avatarView.frame) - self.model.bubbleLeftSpace - size.width;
            } else {
                left = cellWidth - self.model.bubbleInsets.right - size.width;
            }
            self.bubbleView.frame = CGRectMake(left, self.model.bubbleInsets.top, size.width, size.height);
        } else if (self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
            //客服气泡
            CGSize size = [self bubbleViewSize:self.model maxWidth:(cellWidth - kBubbleViewMinMargin)];
            CGFloat left = 0;
            if (showAvatar) {
                left = CGRectGetMaxX(self.avatarView.frame) + self.model.bubbleLeftSpace;
            } else {
                left = self.model.bubbleInsets.left;
            }
            self.bubbleView.frame = CGRectMake(left, self.model.bubbleInsets.top, size.width, size.height);
        }
        UIEdgeInsets insets = self.model.contentInsets;
        self.customContentView.frame = CGRectMake(insets.left,
                                                  insets.top,
                                                  CGRectGetWidth(self.bubbleView.frame) - insets.left - insets.right,
                                                  CGRectGetHeight(self.bubbleView.frame) - insets.top - insets.bottom);
    } else {
        if (showAvatar && self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
            UIEdgeInsets insets = self.model.contentInsets;
            self.customContentView.frame = CGRectMake(insets.left,
                                                      insets.top,
                                                      CGRectGetMinX(self.avatarView.frame) - insets.right,
                                                      cellHeight - insets.top - insets.bottom);
        } else if (showAvatar && self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
            UIEdgeInsets insets = self.model.contentInsets;
            self.customContentView.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + insets.left,
                                                      insets.top,
                                                      cellWidth - CGRectGetMaxX(self.avatarView.frame) - insets.left - insets.right,
                                                      cellHeight - insets.top - insets.bottom);
        } else {
            UIEdgeInsets insets = self.model.contentInsets;
            self.customContentView.frame = CGRectMake(insets.left,
                                                      insets.top,
                                                      cellWidth - insets.left - insets.right,
                                                      cellHeight - insets.top - insets.bottom);
        }
    }
}

#pragma mark - action
- (void)onTapAvatar:(id)sender {
    if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(onTapAvatar:)]) {
        QYCustomEvent *event = [[QYCustomEvent alloc] init];
        event.eventName = QYCustomEventTapAvatar;
        event.message = self.model.message;
        [self.messageDelegate onTapAvatar:event];
    }
}

- (void)longGesturePress:(UIGestureRecognizer*)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (state == UIGestureRecognizerStateBegan) {
            if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(onLongPressCell:)]) {
                QYCustomEvent *event = [[QYCustomEvent alloc] init];
                event.eventName = QYCustomEventLongPressCell;
                event.message = self.model.message;
                [self.messageDelegate onLongPressCell:event];
            }
            self.bubbleView.highlighted = YES;
        } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
            self.bubbleView.highlighted = NO;
        }
    }
}

#pragma mark - private
- (void)resetCustomContentView {
    [self.customContentView removeFromSuperview];
    if (self.model.shouldShowBubble) {
        [self.bubbleView addSubview:self.customContentView];
        [self.bubbleView bringSubviewToFront:self.customContentView];
    } else {
        [self.contentView addSubview:self.customContentView];
        [self.contentView bringSubviewToFront:self.customContentView];
    }
    self.customContentView.userInteractionEnabled = YES;
}

- (CGSize)bubbleViewSize:(QYCustomModel *)model maxWidth:(CGFloat)maxWidth {
    CGSize bubbleSize = CGSizeZero;
    CGSize contentSize = self.model.contentSize;
    if (contentSize.width > maxWidth) {
        contentSize.width = maxWidth;
    }
    UIEdgeInsets insets = self.model.contentInsets;
    bubbleSize.width = contentSize.width + insets.left + insets.right;
    bubbleSize.height = contentSize.height + insets.top + insets.bottom;
    return bubbleSize;
}

- (UIImage *)normalBubbleImage {
    if (self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
        //访客气泡
        return [QYCustomUIConfig sharedInstance].customerMessageBubbleNormalImage;
    } else if (self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
        //访客气泡
        return [QYCustomUIConfig sharedInstance].serviceMessageBubbleNormalImage;
    }
    return nil;
}

- (UIImage *)highlightedBubbleImage {
    if (self.model.message.sourceType == QYCustomMessageSourceTypeSend) {
        //访客气泡
        return [QYCustomUIConfig sharedInstance].customerMessageBubblePressedImage;
    } else if (self.model.message.sourceType == QYCustomMessageSourceTypeReceive) {
        //访客气泡
        return [QYCustomUIConfig sharedInstance].serviceMessageBubblePressedImage;
    }
    return nil;
}

@end

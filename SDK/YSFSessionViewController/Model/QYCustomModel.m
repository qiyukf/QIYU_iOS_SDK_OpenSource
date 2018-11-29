//
//  QYCustomModel.m
//  YSFSDK
//
//  Created by liaosipei on 2018/11/22.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYCustomModel.h"
#import "QYCustomModel_Private.h"
#import "QYCustomMessage_Private.h"
#import "YSFCustomMessageAttachment.h"

@implementation QYCustomModel
#pragma mark - init
- (instancetype)initWithMessage:(YSF_NIMMessage *)message {
    self = [super init];
    if (self) {
        self.ysfMessage = message;
    }
    return self;
}

- (void)setYsfMessage:(YSF_NIMMessage *)ysfMessage {
    _ysfMessage = ysfMessage;
    if (ysfMessage.messageType == YSF_NIMMessageTypeCustom
        && [ysfMessage.messageObject isKindOfClass:[YSF_NIMCustomObject class]]) {
        YSF_NIMCustomObject *customObj = (YSF_NIMCustomObject *)ysfMessage.messageObject;
        if ([customObj.attachment isKindOfClass:[YSFCustomMessageAttachment class]]) {
            YSFCustomMessageAttachment *attachment = (YSFCustomMessageAttachment *)customObj.attachment;
            if ([attachment.message isKindOfClass:[QYCustomMessage class]]) {
                _message = attachment.message;
            }
        }
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[QYCustomModel class]]) {
        return NO;
    }
    QYCustomModel *model = object;
    return [model.ysfMessage isEqual:self.ysfMessage];
}

#pragma mark - getter method
- (BOOL)shouldShowAvatar {
    _shouldShowAvatar = [self needShowAvatar];
    return _shouldShowAvatar;
}

- (BOOL)shouldShowBubble {
    _shouldShowBubble = [self needShowBubble];
    return _shouldShowBubble;
}

- (UIEdgeInsets)contentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, UIEdgeInsetsZero)) {
        _contentInsets = [self contentViewInsets];
    }
    return _contentInsets;
}

- (UIEdgeInsets)bubbleInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_bubbleInsets, UIEdgeInsetsZero)) {
        _bubbleInsets = [self bubbleViewInsets];
    }
    return _bubbleInsets;
}

- (CGFloat)bubbleLeftSpace {
    if (_bubbleLeftSpace == 0) {
        _bubbleLeftSpace = [self avatarBubbleSpace];
    }
    return _bubbleLeftSpace;
}

#pragma mark - QYCustomModelLayoutDataSource
- (NSString *)cellReuseIdentifier {
    return @"QYCustomModelReuseIdentifier";
}

- (CGSize)contentSizeForBubbleMaxWidth:(CGFloat)bubbleMaxWidth {
    return CGSizeMake(bubbleMaxWidth, 40);
}

-(BOOL)needShowAvatar {
    return YES;
}

- (BOOL)needShowBubble {
    return YES;
}

- (UIEdgeInsets)contentViewInsets {
    if (self.shouldShowBubble) {
        if (self.message.sourceType == QYCustomMessageSourceTypeSend) {
            return UIEdgeInsetsMake(0, 0, 0, 4);
        } else if (self.message.sourceType == QYCustomMessageSourceTypeReceive) {
            return UIEdgeInsetsMake(0, 4, 0, 0);
        }
    }
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets)bubbleViewInsets {
    return UIEdgeInsetsMake(3, 0, 13, 0);
}

- (CGFloat)avatarBubbleSpace {
    return 5;
}

#pragma mark - calculate
- (void)calculateContent:(CGFloat)width {
    if (CGSizeEqualToSize(_contentSize, CGSizeZero)) {
        _contentSize = [self contentSizeForBubbleMaxWidth:width - kBubbleViewMinMargin];
    }
}

- (void)recalculateContent:(CGFloat)width {
    if (_contentSize.width != width) {
        _contentSize = [self contentSizeForBubbleMaxWidth:width - kBubbleViewMinMargin];
    }
}

#pragma mark - clean
- (void)cleanCache {
    _contentSize = CGSizeZero;
    _contentInsets = UIEdgeInsetsZero;
    _bubbleInsets = UIEdgeInsetsZero;
    _bubbleLeftSpace = 0;
    _shouldShowAvatar = NO;
    _shouldShowBubble = NO;
}

@end

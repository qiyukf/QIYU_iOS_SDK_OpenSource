//
//  NIMMessageModel.m
//  YSFKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageModel.h"
#import "YSFDefaultValueMaker.h"
#import "YSFSessionConfigImp.h"


@interface YSFMessageModel()

@property (nonatomic, strong, readwrite) id<YSFCellLayoutConfig> layoutConfig;
@property (nonatomic, assign, readwrite) CGSize contentSize;
@property (nonatomic, assign, readwrite) UIEdgeInsets contentViewInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets bubbleViewInsets;
@property (nonatomic, assign, readwrite) CGFloat avatarBubbleSpace;
@property (nonatomic, assign, readwrite) BOOL shouldShowAvatar;
@property (nonatomic, assign, readwrite) BOOL shouldShowNickName;

@property (nonatomic, strong, readwrite) id<YSFExtraCellLayoutConfig> extraLayoutConfig;
@property (nonatomic, assign, readwrite) CGSize extraViewSize;
@property (nonatomic, assign, readwrite) UIEdgeInsets extraViewInsets;
@property (nonatomic, assign, readwrite) BOOL shouldShowExtraView;

@end


@implementation YSFMessageModel

//仅在同时重写了setter和getter时需要手动合成实例变量
@synthesize layoutConfig = _layoutConfig;

- (instancetype)initWithMessage:(YSF_NIMMessage *)message {
    if (self = [self init]) {
        _message = message;
    }
    return self;
}

- (NSString *)description {
    return self.message.text;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[YSFMessageModel class]]) {
        return NO;
    } else {
        YSFMessageModel *model = object;
        return [self.message isEqual:model.message];
    }
}

#pragma mark - setter method
- (void)setLayoutConfig:(id<YSFCellLayoutConfig>)layoutConfig {
    _layoutConfig = layoutConfig;
    if ([layoutConfig respondsToSelector:@selector(shouldShowAvatar:)]) {
        _shouldShowAvatar = [layoutConfig shouldShowAvatar:self];
    } else {
        _shouldShowAvatar = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig shouldShowAvatar:self];
    }
    
    if ([layoutConfig respondsToSelector:@selector(shouldShowNickName:)]) {
        _shouldShowNickName = [layoutConfig shouldShowNickName:self];
    } else {
        _shouldShowNickName = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig shouldShowNickName:self];
    }
}

#pragma mark - getter method
- (id<YSFCellLayoutConfig>)layoutConfig {
    if (_layoutConfig == nil) {
        id<YSFCellLayoutConfig> layoutConfig;
        if ([[YSFSessionConfigImp sharedInstance] respondsToSelector:@selector(layoutConfigWithMessage:)]) {
            layoutConfig = [[YSFSessionConfigImp sharedInstance] layoutConfigWithMessage:_message];
        }
        if (!layoutConfig) {
            layoutConfig = [YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig;
        }
        self.layoutConfig = layoutConfig;
    }
    return _layoutConfig;
}

- (UIEdgeInsets)contentViewInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, UIEdgeInsetsZero)) {
        if ([self.layoutConfig respondsToSelector:@selector(contentViewInsets:)]) {
            _contentViewInsets = [self.layoutConfig contentViewInsets:self];
        } else {
            _contentViewInsets = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig contentViewInsets:self];
        }
    }
    return _contentViewInsets;
}

- (UIEdgeInsets)bubbleViewInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_bubbleViewInsets, UIEdgeInsetsZero)) {
        if ([self.layoutConfig respondsToSelector:@selector(cellInsets:)]) {
            _bubbleViewInsets = [self.layoutConfig cellInsets:self];
        } else {
            _bubbleViewInsets = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig cellInsets:self];
        }
    }
    return _bubbleViewInsets;
}

- (CGFloat)avatarBubbleSpace {
    if (_avatarBubbleSpace == 0) {
        if ([self.layoutConfig respondsToSelector:@selector(headBubbleSpace:)]) {
            _avatarBubbleSpace = [self.layoutConfig headBubbleSpace:self];
        } else {
            _avatarBubbleSpace = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig headBubbleSpace:self];
        }
    }
    return _avatarBubbleSpace;
}

#pragma mark - extra layout
- (id<YSFExtraCellLayoutConfig>)extraLayoutConfig {
    if (!_extraLayoutConfig) {
        _extraLayoutConfig = [YSFDefaultValueMaker sharedMaker].extraCellLayoutConfig;
    }
    return _extraLayoutConfig;
}

- (UIEdgeInsets)extraViewInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_extraViewInsets, UIEdgeInsetsZero)) {
        _extraViewInsets = [self.extraLayoutConfig extraViewInsets:self];
    }
    return _extraViewInsets;
}

- (BOOL)shouldShowExtraView {
    if ([self.layoutConfig respondsToSelector:@selector(shouldShowExtraView:)]) {
        return [self.layoutConfig shouldShowExtraView:self];
    }
    return NO;
}

#pragma mark - calculate
- (void)calculateContent:(CGFloat)width {
    if (CGSizeEqualToSize(_extraViewSize, CGSizeZero)) {
        _extraViewSize = [self.extraLayoutConfig extraViewSize:self];
    }
    
    if (CGSizeEqualToSize(_contentSize, CGSizeZero)) {
        _contentSize = [self.layoutConfig contentSize:self cellWidth:width];
    }
}

- (void)reCalculateContent:(CGFloat)width {
    _extraViewSize = [self.extraLayoutConfig extraViewSize:self];
    
    if (_contentSize.width != width) {
        _contentSize = [self.layoutConfig contentSize:self cellWidth:width];
    }
}

#pragma mark - clean
- (void)cleanLayoutConfig {
    self.layoutConfig = nil;
    self.extraLayoutConfig = nil;
}

- (void)cleanCache {
    _contentSize = CGSizeZero;
    _contentViewInsets = UIEdgeInsetsZero;
    _bubbleViewInsets = UIEdgeInsetsZero;
    _avatarBubbleSpace = 0;
    
    _extraViewSize = CGSizeZero;
    _extraViewInsets = UIEdgeInsetsZero;
}

@end

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

@property (nonatomic,strong) id<YSFCellLayoutConfig> layoutConfig;
@property (nonatomic, strong, readwrite) id<YSFDianZanViewLayoutConfig> dianZanLayoutConfig;
@end


@implementation YSFMessageModel

@synthesize layoutConfig        = _layoutConfig;
@synthesize contentSize        = _contentSize;
@synthesize contentViewInsets  = _contentViewInsets;
@synthesize bubbleViewInsets   = _bubbleViewInsets;
@synthesize shouldShowAvatar   = _shouldShowAvatar;
@synthesize shouldShowNickName = _shouldShowNickName;

@synthesize dianZanViewSize = _dianZanViewSize;
@synthesize dianZanViewInsets = _dianZanViewInsets;
@synthesize shouldShowDianZan = _shouldShowDianZan;

- (instancetype)initWithMessage:(YSF_NIMMessage*)message
{
    if (self = [self init])
    {
        _message = message;
    }
    return self;
}

- (void)cleanLayoutConfig
{
    self.layoutConfig = nil;
    self.dianZanLayoutConfig = nil;
}

- (void)cleanCache
{
    _contentSize = CGSizeZero;
    _bubbleViewInsets = UIEdgeInsetsZero;
    _contentViewInsets = UIEdgeInsetsZero;
    
    _dianZanViewSize = CGSizeZero;
    _dianZanViewInsets = UIEdgeInsetsZero;
}

- (NSString*)description{
    return self.message.text;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[YSFMessageModel class]])
    {
        return NO;
    }
    else
    {
        YSFMessageModel *model = object;
        return [self.message isEqual:model.message];
    }
}

- (void)calculateContent:(CGFloat)width{
    if (CGSizeEqualToSize(_dianZanViewSize, CGSizeZero))
    {
        _dianZanViewSize = [self.dianZanLayoutConfig dianZanViewSize:self];
    }
    
    if (CGSizeEqualToSize(_contentSize, CGSizeZero))
    {
        _contentSize = [self.layoutConfig contentSize:self cellWidth:width];
    }
}

- (void)reCalculateContent:(CGFloat)width{
    _dianZanViewSize = [self.dianZanLayoutConfig dianZanViewSize:self];
    
    if (_contentSize.width != width) {
        _contentSize = [self.layoutConfig contentSize:self cellWidth:width];
    }
}


- (UIEdgeInsets)contentViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, UIEdgeInsetsZero))
    {
        if ([self.layoutConfig respondsToSelector:@selector(contentViewInsets:)])
        {
            _contentViewInsets = [self.layoutConfig contentViewInsets:self];
        }
        else
        {
            _contentViewInsets = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig contentViewInsets:self];
        }
    }
    return _contentViewInsets;
}

- (UIEdgeInsets)bubbleViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_bubbleViewInsets, UIEdgeInsetsZero))
    {
        if ([self.layoutConfig respondsToSelector:@selector(cellInsets:)])
        {
            _bubbleViewInsets = [self.layoutConfig cellInsets:self];
        }
        else
        {
            _bubbleViewInsets = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig cellInsets:self];
        }
    }
    return _bubbleViewInsets;
}

- (id<YSFCellLayoutConfig>)layoutConfig
{
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

- (void)setLayoutConfig:(id<YSFCellLayoutConfig>)layoutConfig
{
    _layoutConfig = layoutConfig;
    if ([layoutConfig respondsToSelector:@selector(shouldShowAvatar:)])
    {
        _shouldShowAvatar = [layoutConfig shouldShowAvatar:self];
    }
    else
    {
        _shouldShowAvatar = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig shouldShowAvatar:self];
    }
    
    if ([layoutConfig respondsToSelector:@selector(shouldShowNickName:)])
    {
        _shouldShowNickName = [layoutConfig shouldShowNickName:self];
    }
    else
    {
        _shouldShowNickName = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig shouldShowNickName:self];
    }
    
    if ([layoutConfig respondsToSelector:@selector(shouldShowDianZan:)]) {
        _shouldShowDianZan = [layoutConfig shouldShowDianZan:self];
    }
    else {
        _shouldShowDianZan = [[YSFDefaultValueMaker sharedMaker].cellLayoutDefaultConfig shouldShowDianZan:self];
    }
}

#pragma mark 点赞视图布局参数

- (id<YSFDianZanViewLayoutConfig>)dianZanLayoutConfig
{
    if (!_dianZanLayoutConfig) {
        _dianZanLayoutConfig = [YSFDefaultValueMaker sharedMaker].dianZanViewLayoutConfig;
    }
    
    return _dianZanLayoutConfig;
}

- (UIEdgeInsets)dianZanViewInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_dianZanViewInsets, UIEdgeInsetsZero)) {
        _dianZanViewInsets = [self.dianZanLayoutConfig dianZanViewInsets:self];
    }
    
    return _dianZanViewInsets;
}

@end

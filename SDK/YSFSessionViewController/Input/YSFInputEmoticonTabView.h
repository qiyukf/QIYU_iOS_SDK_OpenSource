//
//  NIMInputEmoticonTabView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFInputEmoticonTabView;

@protocol YSFInputEmoticonTabDelegate <NSObject>

- (void)tabView:(YSFInputEmoticonTabView *)tabView didSelectTabIndex:(NSInteger) index;

@end

@interface YSFInputEmoticonTabView : UIControl

@property (nonatomic,readonly) NSArray *emoticonCatalogs;

@property (nonatomic,strong) UIButton * sendButton;

@property (nonatomic,weak)   id<YSFInputEmoticonTabDelegate>  delegate;

- (instancetype)initWithFrame:(CGRect)frame catalogs:(NSArray*)emoticonCatalogs;

- (void)selectTabIndex:(NSInteger)index;

@end







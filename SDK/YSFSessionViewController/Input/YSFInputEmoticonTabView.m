//
//  NIMInputEmoticonTabView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputEmoticonTabView.h"
#import "YSFInputEmoticonManager.h"


const NSInteger YSF_NIMInputEmoticonTabViewHeight = 36;

const CGFloat YSF_NIMInputLineBoarder = .5f;

@interface YSFInputEmoticonTabView()

@property (nonatomic,strong) NSMutableArray * tabs;

@property (nonatomic,strong) NSMutableArray * seps;

@end


@implementation YSFInputEmoticonTabView
- (instancetype)initWithFrame:(CGRect)frame catalogs:(NSArray*)emoticonCatalogs{
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, YSF_NIMInputEmoticonTabViewHeight)];
    if (self) {
        _emoticonCatalogs = emoticonCatalogs;
        _tabs = [[NSMutableArray alloc] init];
        _seps = [[NSMutableArray alloc] init];
        UIColor *sepColor = YSFColorFromRGB(0x8A8E93);
        for (YSFInputEmoticonCatalog * catelog in emoticonCatalogs) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage ysf_fetchImage:catelog.icon] forState:UIControlStateNormal];
            [button setImage:[UIImage ysf_fetchImage:catelog.iconPressed] forState:UIControlStateHighlighted];
            [button setImage:[UIImage ysf_fetchImage:catelog.iconPressed] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(onTouchTab:) forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            [self addSubview:button];
            [_tabs addObject:button];
            
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YSF_NIMInputLineBoarder, YSF_NIMInputEmoticonTabViewHeight)];
            sep.backgroundColor = sepColor;
            [_seps addObject:sep];
            [self addSubview:sep];
        }
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
        
        [_sendButton setBackgroundImage:[UIImage ysf_imageInKit:@"icon_input_send_btn_normal"] forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage ysf_imageInKit:@"icon_input_send_btn_pressed"] forState:UIControlStateHighlighted];
        
        [_sendButton sizeToFit];
        [self addSubview:_sendButton];
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.ysf_frameWidth,YSF_NIMInputLineBoarder)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = sepColor;
        [self addSubview:view];
    }
    return self;
}

- (void)onTouchTab:(id)sender{
    NSInteger index = [self.tabs indexOfObject:sender];
    [self selectTabIndex:index];
    if ([self.delegate respondsToSelector:@selector(tabView:didSelectTabIndex:)]) {
        [self.delegate tabView:self didSelectTabIndex:index];
    }
}


- (void)selectTabIndex:(NSInteger)index{
    for (NSInteger i = 0; i < self.tabs.count ; i++) {
        UIButton *btn = self.tabs[i];
        btn.selected = i == index;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat spacing = 10;
    CGFloat left    = spacing;
    for (NSInteger index = 0; index < self.tabs.count ; index++) {
        UIButton *button = self.tabs[index];
        button.ysf_frameLeft = left;
        button.ysf_frameCenterY = self.ysf_frameHeight * .5f;
        
        UIView *sep = self.seps[index];
        sep.ysf_frameLeft = button.ysf_frameRight + spacing;
        left = sep.ysf_frameRight + spacing;
    }
    _sendButton.ysf_frameTop = 3;
    _sendButton.ysf_frameRight = self.ysf_frameWidth - 5;
}


@end


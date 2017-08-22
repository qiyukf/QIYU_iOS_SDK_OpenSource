//
//  YSFInputMoreContainerView.m
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFInputMoreContainerView.h"
#import "YSFPageView.h"
#import "YSFMediaItem.h"
#import "YSFDefaultValueMaker.h"

NSInteger YSF_NIMMaxItemCountInPage = 8;
NSInteger YSF_NIMButtonItemWidth = 74;
NSInteger YSF_NIMButtonItemHeight = 85;
NSInteger YSF_NIMPageRowCount     = 2;
NSInteger YSF_NIMPageColumnCount  = 4;
NSInteger YSF_NIMButtonBegintLeftX = 11;




@interface YSFInputMoreContainerView() <YSFPageViewDataSource,YSFPageViewDelegate>
{
    NSArray                 *_mediaButtons;
    NSArray                 *_mediaItems;
    YSFPageView             *_pageView;
}

@end

@implementation YSFInputMoreContainerView

- (void)setConfig:(id<YSFSessionConfig>)config
{
    _config = config;
    [self genMediaButtons];
}


- (void)genMediaButtons
{
    NSMutableArray *mediaButtons = [NSMutableArray array];
    NSMutableArray *mediaItems = [NSMutableArray array];
    
    if (self.config && [self.config respondsToSelector:@selector(mediaItems)]) {
        NSArray *items = [self.config mediaItems];
        
        [items enumerateObjectsUsingBlock:^(YSFMediaItem *item, NSUInteger idx, BOOL *stop) {
            
            BOOL shouldHidden = NO;
            if ([self.config respondsToSelector:@selector(shouldHideItem:)]) {
                shouldHidden = [self.config shouldHideItem:item];
            }
            
            if (!shouldHidden) {
                
                [mediaItems addObject:item];
                
                UIButton *btn = [[UIButton alloc] init];
                [btn setImage:item.normalImage forState:UIControlStateNormal];
                [btn setImage:item.selectedImage forState:UIControlStateHighlighted];
                [btn setTitle:item.title forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(76, -72, 0, 0)];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
                btn.tag = item.tag;
                [mediaButtons addObject:btn];

            }
        }];
    }
    
    _mediaButtons = mediaButtons;
    _mediaItems = mediaItems;
    
    _pageView = [[YSFPageView alloc] initWithFrame:self.bounds];
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pageView.dataSource = self;
    [self addSubview:_pageView];
    [_pageView scrollToPage:0];
}

- (void)setFrame:(CGRect)frame{
    CGFloat originalWidth = self.frame.size.width;
    [super setFrame:frame];
    if (originalWidth != frame.size.width) {
        [_pageView reloadData];
    }
}


- (void)dealloc
{
    _pageView.dataSource = nil;
}


#pragma mark PageViewDataSource
- (NSInteger)numberOfPages: (YSFPageView *)pageView
{
    NSInteger count = [_mediaButtons count] / YSF_NIMMaxItemCountInPage;
    count = ([_mediaButtons count] % YSF_NIMMaxItemCountInPage == 0) ? count: count + 1;
    return MAX(count, 1);
}

- (UIView*)mediaPageView:(YSFPageView*)pageView beginItem:(NSInteger)begin endItem:(NSInteger)end
{
    UIView *subView = [[UIView alloc] init];
    NSInteger span = (self.ysf_frameWidth - YSF_NIMPageColumnCount * YSF_NIMButtonItemWidth) / (YSF_NIMPageColumnCount +1);
    CGFloat startY          = YSF_NIMButtonBegintLeftX;
    NSInteger coloumnIndex = 0;
    NSInteger rowIndex = 0;
    NSInteger indexInPage = 0;
    for (NSInteger index = begin; index < end; index ++)
    {
        UIButton *button = [_mediaButtons objectAtIndex:index];
        [button addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        //计算位置
        rowIndex    = indexInPage / YSF_NIMPageColumnCount;
        coloumnIndex= indexInPage % YSF_NIMPageColumnCount;
        CGFloat x = span + (YSF_NIMButtonItemWidth + span) * coloumnIndex;
        CGFloat y = 0.0;
        if (rowIndex > 0)
        {
            y = rowIndex * YSF_NIMButtonItemHeight + startY + 15;
        }
        else
        {
            y = rowIndex * YSF_NIMButtonItemHeight + startY;
        }
        [button setFrame:CGRectMake(x, y, YSF_NIMButtonItemWidth, YSF_NIMButtonItemHeight)];
        [subView addSubview:button];
        indexInPage ++;
    }
    return subView;
}

- (UIView*)oneLineMediaInPageView:(YSFPageView *)pageView
                       viewInPage: (NSInteger)index
                            count:(NSInteger)count
{
    UIView *subView = [[UIView alloc] init];
    NSInteger span = (self.ysf_frameWidth - count * YSF_NIMButtonItemWidth) / (count +1);
    
    for (NSInteger btnIndex = 0; btnIndex < count; btnIndex ++)
    {
        UIButton *button = [_mediaButtons objectAtIndex:btnIndex];
        [button addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        CGRect iconRect = CGRectMake(span + (YSF_NIMButtonItemWidth + span) * btnIndex, 58, YSF_NIMButtonItemWidth, YSF_NIMButtonItemHeight);
        [button setFrame:iconRect];
        [subView addSubview:button];
    }
    return subView;
}

- (UIView *)pageView: (YSFPageView *)pageView viewInPage: (NSInteger)index
{
    if ([_mediaButtons count] == 2 || [_mediaButtons count] == 3) //一行显示2个或者3个
    {
        return [self oneLineMediaInPageView:pageView viewInPage:index count:[_mediaButtons count]];
    }
    
    if (index < 0)
    {
        //assert(0);
        index = 0;
    }
    NSInteger begin = index * YSF_NIMMaxItemCountInPage;
    NSInteger end = (index + 1) * YSF_NIMMaxItemCountInPage;
    if (end > [_mediaButtons count])
    {
        end = [_mediaButtons count];
    }
    return [self mediaPageView:pageView beginItem:begin endItem:end];
}

#pragma mark - button actions
- (void)onTouchButton:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    for (YSFMediaItem *item in _mediaItems) {
        if (item.tag == tag) {
            if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onTapMediaItem:)]) {
                [_actionDelegate onTapMediaItem:item];
            }
            break;
        }
    }
}

@end

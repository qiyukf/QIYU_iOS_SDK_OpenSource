//
//  NIMInputEmoticonContainerView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputEmoticonContainerView.h"
#import "YSFPageView.h"
#import "YSFInputEmoticonButton.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonTabView.h"
#import "YSFInputEmoticonDefine.h"

NSInteger YSF_NIMCustomPageControlHeight = 36;
NSInteger YSF_NIMCustomPageViewHeight    = 159;

@interface YSFInputEmoticonContainerView()<YSFEmoticonButtonTouchDelegate,YSFInputEmoticonTabDelegate>

@property (nonatomic,strong) NSMutableArray *pageData;

@end


@implementation YSFInputEmoticonContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadConfig];
        [self loadUIComponents];
    }
    return self;
}

- (void)loadConfig{
    self.backgroundColor = [UIColor clearColor];
}

- (void)loadUIComponents
{
    _emoticonPageView                  = [[YSFPageView alloc] initWithFrame:self.bounds];
    _emoticonPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _emoticonPageView.ysf_frameHeight    = YSF_NIMCustomPageViewHeight;
    _emoticonPageView.backgroundColor  = [UIColor clearColor];
    _emoticonPageView.dataSource       = self;
    _emoticonPageView.pageViewDelegate = self;
    [self addSubview:_emoticonPageView];
    
    _emotPageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.ysf_frameWidth, YSF_NIMCustomPageControlHeight)];
    _emotPageController.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _emotPageController.pageIndicatorTintColor = [UIColor lightGrayColor];
    _emotPageController.currentPageIndicatorTintColor = [UIColor grayColor];
    [self addSubview:_emotPageController];
    [_emotPageController setUserInteractionEnabled:NO];
    
    
    NSArray *catalogs = [self reloadData];
    _tabView = [[YSFInputEmoticonTabView alloc] initWithFrame:CGRectZero catalogs:catalogs];
    _tabView.delegate = self;
    [_tabView.sendButton addTarget:self action:@selector(didPressSend:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tabView];
    
    if (_currentCatalogData.pagesCount > 0) {
        _emotPageController.numberOfPages = [_currentCatalogData pagesCount];
        _emotPageController.currentPage = 0;
        [_emoticonPageView scrollToPage:0];
    }
}


- (void)setFrame:(CGRect)frame{
    CGFloat originalWidth = self.frame.size.width;
    [super setFrame:frame];
    if (originalWidth != frame.size.width) {
        [self reloadData];
    }
}

- (NSArray *)reloadData{
    YSFInputEmoticonCatalog * defaultCatalog = [self loadDefaultCatalog];
    NSArray *charlets = [self loadChartlet];
    NSArray *catalogs = defaultCatalog? [@[defaultCatalog] arrayByAddingObjectsFromArray:charlets] : charlets;
    self.currentCatalogData = catalogs.firstObject;
    return catalogs;
}


#define EmotPageControllerMarginBottom 10
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.emotPageController.ysf_frameTop = self.emoticonPageView.ysf_frameBottom - EmotPageControllerMarginBottom;
    _tabView.ysf_frameBottom = self.ysf_frameHeight;
    _tabView.ysf_frameWidth = self.ysf_frameWidth;
}



#pragma mark -  config data

- (NSInteger)sumPages
{
    __block NSInteger pagesCount = 0;
    [self.tabView.emoticonCatalogs enumerateObjectsUsingBlock:^(YSFInputEmoticonCatalog* data, NSUInteger idx, BOOL *stop) {
        pagesCount += data.pagesCount;
    }];
    return pagesCount;
}


- (UIView*)emojPageView:(YSFPageView*)pageView inEmoticonCatalog:(YSFInputEmoticonCatalog *)emoticon page:(NSInteger)page
{
    UIView *subView = [[UIView alloc] init];
    NSInteger iconHeight    = emoticon.layout.imageHeight;
    NSInteger iconWidth     = emoticon.layout.imageWidth;
    CGFloat startX          = (emoticon.layout.cellWidth - iconWidth) / 2  + YSFKit_EmojiLeftMargin;
    CGFloat startY          = (emoticon.layout.cellHeight- iconHeight) / 2 + YSFKit_EmojiTopMargin;
    int32_t coloumnIndex = 0;
    int32_t rowIndex = 0;
    int32_t indexInPage = 0;
    NSInteger begin = page * emoticon.layout.itemCountInPage;
    NSInteger end   = begin + emoticon.layout.itemCountInPage;
    end = end > emoticon.emoticons.count ? (emoticon.emoticons.count) : end;
    for (NSInteger index = begin; index < end; index ++)
    {
        YSFInputEmoticon *data = [emoticon.emoticons objectAtIndex:index];
        
        YSFInputEmoticonButton *button = [YSFInputEmoticonButton iconButtonWithData:data catalogID:emoticon.catalogID delegate:self];
        //计算表情位置
        rowIndex    = indexInPage / emoticon.layout.columes;
        coloumnIndex= indexInPage % emoticon.layout.columes;
        CGFloat x = coloumnIndex * emoticon.layout.cellWidth + startX;
        CGFloat y = rowIndex * emoticon.layout.cellHeight + startY;
        CGRect iconRect = CGRectMake(x, y, iconWidth, iconHeight);
        [button setFrame:iconRect];
        [subView addSubview:button];
        indexInPage ++;
    }
    if (coloumnIndex == emoticon.layout.columes -1)
    {
        rowIndex = rowIndex +1;
        coloumnIndex = -1; //设置成-1是因为显示在第0位，有加1
    }
    if ([emoticon.catalogID isEqualToString:YSFKit_EmojiCatalog]) {
        [self addDeleteEmotButtonToView:subView  ColumnIndex:coloumnIndex RowIndex:rowIndex StartX:startX StartY:startY IconWidth:iconWidth IconHeight:iconHeight inEmoticonCatalog:emoticon];
    }
    return subView;
}

- (void)addDeleteEmotButtonToView:(UIView *)view
                      ColumnIndex:(NSInteger)coloumnIndex
                         RowIndex:(NSInteger)rowIndex
                           StartX:(CGFloat)startX
                           StartY:(CGFloat)startY
                        IconWidth:(CGFloat)iconWidth
                       IconHeight:(CGFloat)iconHeight
                inEmoticonCatalog:(YSFInputEmoticonCatalog *)emoticon
{
    YSFInputEmoticonButton* deleteIcon = [[YSFInputEmoticonButton alloc] init];
    deleteIcon.delegate = self;
    deleteIcon.userInteractionEnabled = YES;
    deleteIcon.exclusiveTouch = YES;
    deleteIcon.contentMode = UIViewContentModeCenter;
    NSString *prefix = [YSFKit_EmoticonPath stringByAppendingPathComponent:YSFKit_EmojiPath];
    NSString *imageNormalName = [prefix stringByAppendingPathComponent:@"emoji_del_normal"];
    NSString *imagePressName = [prefix stringByAppendingPathComponent:@"emoji_del_pressed"];
    UIImage *imageNormal  = [UIImage ysf_imageInKit:imageNormalName];
    UIImage *imagePressed = [UIImage ysf_imageInKit:imagePressName];
    
    [deleteIcon setImage:imageNormal forState:UIControlStateNormal];
    [deleteIcon setImage:imagePressed forState:UIControlStateHighlighted];
    [deleteIcon addTarget:deleteIcon action:@selector(onIconSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat newX = (coloumnIndex +1) * emoticon.layout.cellWidth + startX;
    CGFloat newY = rowIndex * emoticon.layout.cellHeight + startY;
    CGRect deleteIconRect = CGRectMake(newX, newY, YSFKit_DeleteIconWidth, YSFKit_DeleteIconHeight);
    
    [deleteIcon setFrame:deleteIconRect];
    [view addSubview:deleteIcon];
}


#pragma mark - pageviewDelegate
- (NSInteger)numberOfPages: (YSFPageView *)pageView
{
    return [self sumPages];
}

- (UIView *)pageView:(YSFPageView *)pageView viewInPage:(NSInteger)index
{
    NSInteger page  = 0;
    YSFInputEmoticonCatalog *emoticon;
    for (emoticon in self.tabView.emoticonCatalogs) {
        NSInteger newPage = page + emoticon.pagesCount;
        if (newPage > index) {
            break;
        }
        page   = newPage;
    }
    return [self emojPageView:pageView inEmoticonCatalog:emoticon page:index - page];
}


- (YSFInputEmoticonCatalog*)loadDefaultCatalog
{
    YSFInputEmoticonCatalog *emoticonCatalog = [[YSFInputEmoticonManager sharedManager] emoticonCatalog:YSFKit_EmojiCatalog];
    if (emoticonCatalog) {
        YSFInputEmoticonLayout *layout = [[YSFInputEmoticonLayout alloc] initEmojiLayout:self.ysf_frameWidth];
        emoticonCatalog.layout = layout;
        emoticonCatalog.pagesCount = [self numberOfPagesWithEmoticon:emoticonCatalog];
    }
    return emoticonCatalog;
}


- (NSArray *)loadChartlet{
    NSArray *chatlets = [[YSFInputEmoticonManager sharedManager] loadChartletEmoticonCatalog];
    for (YSFInputEmoticonCatalog *item in chatlets) {
        YSFInputEmoticonLayout *layout = [[YSFInputEmoticonLayout alloc] initCharletLayout:self.ysf_frameWidth];
        item.layout = layout;
        item.pagesCount = [self numberOfPagesWithEmoticon:item];
    }
    return chatlets;
}


//找到某组表情的起始位置
- (NSInteger)pageIndexWithEmoticon:(YSFInputEmoticonCatalog *)emoticonCatalog{
    NSInteger pageIndex = 0;
    for (YSFInputEmoticonCatalog *emoticon in self.tabView.emoticonCatalogs) {
        if (emoticon == emoticonCatalog) {
            break;
        }
        pageIndex += emoticon.pagesCount;
    }
    return pageIndex;
}

- (NSInteger)pageIndexWithTotalIndex:(NSInteger)index{
    YSFInputEmoticonCatalog *catelog = [self emoticonWithIndex:index];
    NSInteger begin = [self pageIndexWithEmoticon:catelog];
    return index - begin;
}

- (YSFInputEmoticonCatalog *)emoticonWithIndex:(NSInteger)index {
    NSInteger page  = 0;
    YSFInputEmoticonCatalog *emoticon;
    for (emoticon in self.tabView.emoticonCatalogs) {
        NSInteger newPage = page + emoticon.pagesCount;
        if (newPage > index) {
            break;
        }
        page   = newPage;
    }
    return emoticon;
}

- (NSInteger)numberOfPagesWithEmoticon:(YSFInputEmoticonCatalog *)emoticonCatalog
{
    if(emoticonCatalog.emoticons.count % emoticonCatalog.layout.itemCountInPage == 0)
    {
        return  emoticonCatalog.emoticons.count / emoticonCatalog.layout.itemCountInPage;
    }
    else
    {
        return  emoticonCatalog.emoticons.count / emoticonCatalog.layout.itemCountInPage + 1;
    }
}

- (void)pageViewScrollEnd: (YSFPageView *)pageView
             currentIndex: (NSInteger)index
               totolPages: (NSInteger)pages{
    YSFInputEmoticonCatalog *emticon = [self emoticonWithIndex:index];
    self.emotPageController.numberOfPages = [emticon pagesCount];
    self.emotPageController.currentPage = [self pageIndexWithTotalIndex:index];
    
    NSInteger selectTabIndex = [self.tabView.emoticonCatalogs indexOfObject:emticon];
    [self.tabView selectTabIndex:selectTabIndex];
}


#pragma mark - EmoticonButtonTouchDelegate
- (void)selectedEmoticon:(YSFInputEmoticon*)emoticon catalogID:(NSString*)catalogID{
    if ([self.delegate respondsToSelector:@selector(selectedEmoticon:catalog:description:)]) {
        [self.delegate selectedEmoticon:emoticon.emoticonID catalog:catalogID description:emoticon.tag];
    }
}

- (void)didPressSend:(id)sender{
    if ([self.delegate respondsToSelector:@selector(didPressSend:)]) {
        [self.delegate didPressSend:sender];
    }
}


#pragma mark - InputEmoticonTabDelegate
- (void)tabView:(YSFInputEmoticonTabView *)tabView didSelectTabIndex:(NSInteger) index{
    self.currentCatalogData = tabView.emoticonCatalogs[index];
}

#pragma mark - Private

- (void)setCurrentCatalogData:(YSFInputEmoticonCatalog *)currentCatalogData{
    _currentCatalogData = currentCatalogData;
    [self.emoticonPageView scrollToPage:[self pageIndexWithEmoticon:_currentCatalogData]];
}

- (YSFInputEmoticonCatalog *)nextCatalogData{
    if (!self.currentCatalogData) {
        return nil;
    }
    NSInteger index = [self.tabView.emoticonCatalogs indexOfObject:self.currentCatalogData];
    if (index >= self.tabView.emoticonCatalogs.count) {
        return nil;
    }else{
        return self.tabView.emoticonCatalogs[index+1];
    }
}

- (NSArray *)allEmoticons{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (YSFInputEmoticonCatalog *catalog in self.tabView.emoticonCatalogs) {
        [array addObjectsFromArray:catalog.emoticons];
    }
    return array;
}

@end


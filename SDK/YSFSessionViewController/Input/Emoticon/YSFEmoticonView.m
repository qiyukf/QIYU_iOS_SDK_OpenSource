//
//  YSFEmoticonView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonView.h"
#import "YSFEmoticonDataManager.h"
#import "YSFEmoticonTabView.h"
#import "YSFEmojiPageView.h"
#import "YSFGraphicPageView.h"
#import "YSFEmoticonTabCell.h"
#import "YSFEmojiCell.h"
#import "YSFGraphicCell.h"
#import "YSFEmoticonLoadingView.h"
#import "YSFReachability.h"
#import "YSFTools.h"


@interface YSFEmoticonView () <UIScrollViewDelegate, YSFEmoticonLoadingViewDelegate, YSFEmoticonTabViewDelegate, YSFEmojiPageViewDelegate, YSFGraphicPageViewDelegate>

@property (nonatomic, strong) NSMutableArray <YSFEmoticonPackage *> *emoticonData;
@property (nonatomic, strong) NSMutableArray <YSFEmoticonLayout *> *layoutData;
@property (nonatomic, assign) NSUInteger totalPageCount;
@property (nonatomic, assign) NSUInteger curIndex;

@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) YSFEmoticonTabView *tabView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic, strong) YSFEmoticonLoadingView *loadingView;

@end


@implementation YSFEmoticonView
- (void)dealloc {
    _loadingView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YSFColorFromRGB(0xf7f7f7);
        _emoticonData = [NSMutableArray array];
        _layoutData = [NSMutableArray array];
        _totalPageCount = 0;
        
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self addSubview:_seperatorLine];
        
        [self loadEmoticonData];
    }
    return self;
}

#pragma mark - Load Data
- (void)loadEmoticonData {
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        if (!YSFEmoticon_KFCustomEnable) {
            [[YSFEmoticonDataManager sharedManager] onlyloadDefaultEmojiData];
            [self loadDataAndView];
            return;
        }
    }
    /**
     * 请求表情数据满足以下条件之一：
     * 1、当前没有表情包数据
     * 2、needRequest标记位为YES（只有表情按钮显示出来后置为YES，请求成功则置为NO，请求失败依旧为YES）
     */
    __weak typeof(self) weakSelf = self;
    if ([[YSFEmoticonDataManager sharedManager].packageList count] == 0) {
        if (![[YSFReachability reachabilityForInternetConnection] isReachable]) {
            [self showloadingView:YSFEmoticonLoadingTypeFail];
            return;
        }
        [self showloadingView:YSFEmoticonLoadingTypeLoading];
        [[YSFEmoticonDataManager sharedManager] requestEmoticonDataCompletion:^(NSError *error) {
            if (!error) {
                //使用新数据构建布局并展示视图
                [weakSelf loadDataAndView];
            } else {
                [weakSelf showloadingView:YSFEmoticonLoadingTypeFail];
            }
        }];
    } else {
        //有以前的旧数据，先使用旧数据构建布局并展示视图
        [self loadDataAndView];
        if ([YSFEmoticonDataManager sharedManager].needRequest) {
            [[YSFEmoticonDataManager sharedManager] requestEmoticonDataCompletion:^(NSError *error) {
                if (!error) {
                    //使用新数据构建布局并展示视图
                    [weakSelf loadDataAndView];
                }
            }];
        }
    }
}

- (void)loadDataAndView {
    if ([[YSFEmoticonDataManager sharedManager].packageList count] == 0) {
        [self showloadingView:YSFEmoticonLoadingTypeNoData];
        return;
    } else {
        [self loadLayoutData];
        [self loadEmoticonView];
        [self removeLoadingView];
    }
}

- (void)loadLayoutData {
    if ([self.layoutData count]) {
        [self.layoutData removeAllObjects];
    }
    if ([self.emoticonData count]) {
        [self.emoticonData removeAllObjects];
    }
    _curIndex = 0;
    _totalPageCount = 0;
    for (YSFEmoticonPackage *package in [YSFEmoticonDataManager sharedManager].packageList) {
        YSFEmoticonPackage *copyPackage = [package copy];
        YSFEmoticonLayout *layout = [[YSFEmoticonLayout alloc] init];
        layout.itemCount = copyPackage.emoticonList.count;
        if (copyPackage.type == YSFEmoticonTypeDefaultEmoji || copyPackage.type == YSFEmoticonTypeCustomEmoji) {
            layout.margin = UIEdgeInsetsMake(YSFEmoticon_kEmojiTopMargin, YSFEmoticon_kEmojiLeftMargin, 0, YSFEmoticon_kEmojiRightMargin);
            layout.rows = YSFEmoticon_kEmojiRows;
            layout.columns = (CGRectGetWidth(self.frame) - layout.margin.left - layout.margin.right) / YSFEmoticon_kEmojiCellWidth;
            layout.itemWidth = floorf((CGRectGetWidth(self.frame) - layout.margin.left - layout.margin.right) / layout.columns);
            layout.itemHeight = YSFEmoticon_kEmojiCellHeight;
            layout.itemInPage = (layout.rows * layout.columns - 1);
            layout.pageCount = ceilf((float)layout.itemCount / layout.itemInPage);
            //最后不满一页的需补足数据
            NSUInteger restNum = layout.pageCount * layout.itemInPage - layout.itemCount;
            for (NSInteger i = 0; i < restNum; i++) {
                YSFEmoticonItem *nullItem = [[YSFEmoticonItem alloc] init];
                nullItem.type = YSFEmoticonTypeNone;
                [copyPackage.emoticonList addObject:nullItem];
            }
            //插入删除按钮数据
            for (NSInteger i = 0; i < layout.pageCount; i++) {
                YSFEmoticonItem *deleteItem = [[YSFEmoticonItem alloc] init];
                deleteItem.type = YSFEmoticonTypeDelete;
                NSUInteger insertIndex = (i + 1) * layout.itemInPage + i;
                if (insertIndex < (layout.pageCount * (layout.rows * layout.columns))) {
                    [copyPackage.emoticonList insertObject:deleteItem atIndex:insertIndex];
                }
            }
        } else if (copyPackage.type == YSFEmoticonTypeCustomGraph) {
            layout.margin = UIEdgeInsetsMake(YSFEmoticon_kGrapgicTopMargin, YSFEmoticon_kGrapgicLeftMargin, 0, YSFEmoticon_kGrapgicRightMargin);
            layout.rows = YSFEmoticon_kGrapgicRows;
            layout.columns = (CGRectGetWidth(self.frame) - layout.margin.left - layout.margin.right) / YSFEmoticon_kGrapgicCellWidth;
            layout.itemWidth = floorf((CGRectGetWidth(self.frame) - layout.margin.left - layout.margin.right) / layout.columns);
            layout.itemHeight = YSFEmoticon_kGrapgicCellHeight;
            layout.itemInPage = (layout.rows * layout.columns);
            layout.pageCount = ceil((float)layout.itemCount / layout.itemInPage);
        }
        [self.emoticonData addObject:copyPackage];
        [self.layoutData addObject:layout];
        _totalPageCount += layout.pageCount;
    }
}

#pragma mark - Init View
- (void)loadEmoticonView {
    CGFloat width = CGRectGetWidth(self.frame);
    //remove
    if ([self.pageViews count]) {
        [self.pageViews removeAllObjects];
    }
    [self removeContentScrollView];
    //tabView
    if (!_tabView) {
        _tabView = [[YSFEmoticonTabView alloc] initWithFrame:CGRectMake(0, YSFEmoticon_kPageScrollHeight, width, YSFEmoticon_kTabHeight)];
        _tabView.delegate = self;
        [self addSubview:_tabView];
    }
    [_tabView reloadEmoticonData:self.emoticonData];
    //scrollView
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, YSFEmoticon_kPageScrollHeight)];
    _contentScrollView.contentSize = CGSizeMake(width * [self.emoticonData count], YSFEmoticon_kPageScrollHeight);
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.delegate = self;
    [self addSubview:_contentScrollView];
    
    for (NSInteger i = 0; i < [self.emoticonData count]; i++) {
        YSFEmoticonPackage *package = [self.emoticonData objectAtIndex:i];
        YSFEmoticonLayout *layout = [self.layoutData objectAtIndex:i];
        if (package.type == YSFEmoticonTypeDefaultEmoji || package.type == YSFEmoticonTypeCustomEmoji) {
            YSFEmojiPageView *pageView = [[YSFEmojiPageView alloc] initWithPackageData:package layoutData:layout];
            pageView.frame = CGRectMake(i * width, 0, width, YSFEmoticon_kPageScrollHeight);
            pageView.delegate = self;
            [_contentScrollView addSubview:pageView];
            [self.pageViews addObject:pageView];
        } else if (package.type == YSFEmoticonTypeCustomGraph) {
            YSFGraphicPageView *pageView = [[YSFGraphicPageView alloc] initWithPackageData:package layoutData:layout];
            pageView.frame = CGRectMake(i * width, 0, width, YSFEmoticon_kPageScrollHeight);
            pageView.delegate = self;
            [_contentScrollView addSubview:pageView];
            [self.pageViews addObject:pageView];
        }
    }
}

- (void)showloadingView:(YSFEmoticonLoadingType)type {
    if (!_loadingView) {
        _loadingView = [[YSFEmoticonLoadingView alloc] initWithFrame:CGRectZero];
        _loadingView.delegate = self;
        [self addSubview:_loadingView];
    }
    _loadingView.hidden = NO;
    _loadingView.type = type;
    [self bringSubviewToFront:_loadingView];
}

- (void)removeLoadingView {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)removeContentScrollView {
    if (_contentScrollView) {
        [_contentScrollView removeFromSuperview];
        _contentScrollView = nil;
    }
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    _seperatorLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0 / [UIScreen mainScreen].scale);
    _loadingView.frame = self.bounds;
    _tabView.frame = CGRectMake(0, YSFEmoticon_kPageScrollHeight, CGRectGetWidth(self.frame), YSFEmoticon_kTabHeight);
    _contentScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), YSFEmoticon_kPageScrollHeight);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.contentScrollView]) {
//        NSLog(@"contentScrollView: x = %f y = %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
        NSUInteger lastPage = self.curIndex;
        NSUInteger curPage = round(scrollView.contentOffset.x / CGRectGetWidth(self.frame));
        if (curPage != lastPage) {
            self.curIndex = curPage;
            [self.tabView reloadView:curPage];
        }
    }
}

#pragma mark - Actions
- (void)tapRefreshButton:(id)sender {
    [self loadEmoticonData];
}

- (void)tapSendButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTouchEmoticonSendButton:)]) {
        [self.delegate onTouchEmoticonSendButton:sender];
    }
}

- (void)selectEmoticonPackage:(YSFEmoticonPackage *)selectPackage indexPath:(NSIndexPath *)indexPath {
    if (selectPackage && indexPath) {
        NSInteger index = indexPath.item;
        if (index >= 0 && index < self.emoticonData.count) {
            [self.contentScrollView setContentOffset:CGPointMake(index * CGRectGetWidth(self.frame), 0)];
        }
    }
}

- (void)selectEmojiItem:(YSFEmoticonItem *)selectItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectEmoticonItem:)]) {
        [self.delegate selectEmoticonItem:selectItem];
    }
}

- (void)selectGraphicItem:(YSFEmoticonItem *)selectItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectEmoticonItem:)]) {
        [self.delegate selectEmoticonItem:selectItem];
    }
}

@end

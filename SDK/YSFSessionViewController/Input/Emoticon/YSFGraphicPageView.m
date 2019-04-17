//
//  YSFGraphicPageView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFGraphicPageView.h"
#import "YSFEmoticonDataManager.h"
#import "YSFGraphicCell.h"
#import "YSFHorizontalPageLayout.h"


@interface YSFGraphicPageView () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) YSFEmoticonPackage *packageData;
@property (nonatomic, strong) YSFEmoticonLayout *layoutData;
@property (nonatomic, assign) NSUInteger curPage;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation YSFGraphicPageView
- (instancetype)initWithPackageData:(YSFEmoticonPackage *)packageData layoutData:(YSFEmoticonLayout *)layoutData {
    self = [super init];
    if (self) {
        _packageData = packageData;
        _layoutData = layoutData;
        [self initCollectionView];
        [self initPageControl];
    }
    return self;
}

- (void)initCollectionView {
    YSFHorizontalPageLayout *layout = [[YSFHorizontalPageLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 6;
    layout.itemSize = CGSizeMake(self.layoutData.itemWidth, self.layoutData.itemHeight);
    layout.sectionInset = self.layoutData.margin;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.delaysContentTouches = NO;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[YSFGraphicCell class] forCellWithReuseIdentifier:YSFGraphicCellIdentifier];
    [self addSubview:_collectionView];
}

- (void)initPageControl {
    if (self.layoutData.pageCount > 1) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.numberOfPages = self.layoutData.pageCount;
        _pageControl.currentPage = 0;
        [self addSubview:_pageControl];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.layoutData.pageCount > 1) {
        _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), YSFEmoticon_kPageViewHeight);
        _pageControl.frame = CGRectMake(0,
                                        CGRectGetMaxY(_collectionView.frame),
                                        CGRectGetWidth(_collectionView.frame),
                                        YSFEmoticon_kPageControlHeight);
    } else {
        _collectionView.frame = CGRectMake(0, 5, CGRectGetWidth(self.frame), YSFEmoticon_kPageViewHeight);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
//        NSLog(@"YSFGraphicPageView: x = %f y = %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
        NSUInteger lastPage = self.curPage;
        NSUInteger curPage = round(scrollView.contentOffset.x / CGRectGetWidth(self.frame));
        if (curPage != lastPage) {
            self.curPage = curPage;
            _pageControl.currentPage = curPage;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.layoutData.itemCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.layoutData.itemWidth, self.layoutData.itemHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YSFGraphicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YSFGraphicCellIdentifier forIndexPath:indexPath];
    YSFEmoticonItem *item = [self.packageData.emoticonList objectAtIndex:indexPath.item];
    cell.itemData = item;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YSFEmoticonItem *item = [self.packageData.emoticonList objectAtIndex:indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectGraphicItem:)]) {
        [self.delegate selectGraphicItem:item];
    }
}

@end

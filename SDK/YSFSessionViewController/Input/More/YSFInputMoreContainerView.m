//
//  YSFInputMoreContainerView.m
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFInputMoreContainerView.h"
#import "YSFTools.h"
#import "QYCustomUIConfig+Private.h"
#import "YSFHorizontalPageLayout.h"
#import "YSFMoreItemCell.h"


@interface YSFInputMoreContainerView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy) NSMutableArray *items;
@property (nonatomic, assign) CGFloat space_x;   //item间横向距离
@property (nonatomic, assign) CGFloat space_y;   //item间竖向距离
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger curPage;

@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation YSFInputMoreContainerView
- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _curPage = 0;
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self addSubview:_seperatorLine];
        
        [self makeData];
        [self initCollectionView];
        [self initPageControl];
    }
    return self;
}

- (void)makeData {
    NSUInteger count = [[QYCustomUIConfig sharedInstance].customInputItems count];
    if (!count) {
        return;
    }
    _items = [[QYCustomUIConfig sharedInstance].customInputItems mutableCopy];
    
    if (count <= YSFMore_kItemColumns) {
        self.pageCount = 1;
        self.space_x = floorf((CGRectGetWidth(self.frame) - count * YSFMore_kCellWidth) / (count + 1));
        self.space_y = floorf((CGRectGetHeight(self.frame) - YSFMore_kCellHeight) / 1.8);
    } else {
        self.pageCount = ceil((float)count / (YSFMore_kItemRows * YSFMore_kItemColumns));
        CGFloat height = (self.pageCount > 1) ? (CGRectGetHeight(self.frame) - YSFMore_kPageControlHeight) : CGRectGetHeight(self.frame);
        self.space_x = floorf((CGRectGetWidth(self.frame) - YSFMore_kItemColumns * YSFMore_kCellWidth) / (YSFMore_kItemColumns + 1));
        self.space_y = floorf((height - YSFMore_kItemRows * YSFMore_kCellHeight) / (YSFMore_kItemRows + 0.8));
    }
}

- (void)initCollectionView {
    YSFHorizontalPageLayout *layout = [[YSFHorizontalPageLayout alloc] init];
    layout.minimumInteritemSpacing = self.space_x;
    layout.minimumLineSpacing = self.space_y;
    layout.itemSize = CGSizeMake(YSFMore_kCellWidth, YSFMore_kCellHeight);
    layout.sectionInset = UIEdgeInsetsMake(self.space_y, self.space_x, ROUND_SCALE(0.8 * self.space_y), self.space_x);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollEnabled = (self.pageCount > 1) ? YES : NO;
    _collectionView.delaysContentTouches = YES;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[YSFMoreItemCell class] forCellWithReuseIdentifier:YSFMoreItemCellIdentifier];
    [self addSubview:_collectionView];
}

- (void)initPageControl {
    if (self.pageCount > 1) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.numberOfPages = self.pageCount;
        _pageControl.currentPage = 0;
        [self addSubview:_pageControl];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _seperatorLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0 / [UIScreen mainScreen].scale);
    if (self.pageCount > 1) {
        _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds) - YSFMore_kPageControlHeight);
        _pageControl.frame = CGRectMake(0,
                                        CGRectGetMaxY(_collectionView.frame),
                                        CGRectGetWidth(_collectionView.frame),
                                        YSFMore_kPageControlHeight);
    } else {
        _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds));
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
//        NSLog(@"YSFEmoticonTabView: x = %f y = %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
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
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YSFMoreItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YSFMoreItemCellIdentifier forIndexPath:indexPath];
    QYCustomInputItem *item = [self.items objectAtIndex:indexPath.item];
    cell.itemData = item;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QYCustomInputItem *item = [self.items objectAtIndex:indexPath.item];
    if (item.block) {
        item.block();
    }
}

@end

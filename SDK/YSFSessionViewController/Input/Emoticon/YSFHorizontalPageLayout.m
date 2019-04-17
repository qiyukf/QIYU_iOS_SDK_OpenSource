//
//  YSFHorizontalPageLayout.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/24.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFHorizontalPageLayout.h"
#import "YSFTools.h"


@interface YSFHorizontalPageLayout ()

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *layoutAttributes;

@end


@implementation YSFHorizontalPageLayout

#pragma mark - Getter
- (NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributes {
    if (_layoutAttributes == nil) {
        _layoutAttributes = [NSMutableArray array];
    }
    return _layoutAttributes;
}

- (NSInteger)rowCount {
    if (_rowCount == 0) {
        CGFloat height = self.collectionView.bounds.size.height - self.sectionInset.top - self.sectionInset.bottom;
        NSInteger numerator = height + self.minimumLineSpacing;
        NSInteger denominator = self.minimumLineSpacing + self.itemSize.height;
        NSInteger count = numerator / denominator;
        _rowCount = count;
        if (numerator % denominator) {
            if (count != 1) {
                self.minimumLineSpacing = (height - count * self.itemSize.height) / (CGFloat)(count - 1);
            }
        }
    }
    return _rowCount;
}

- (NSInteger)columnCount {
    if (_columnCount == 0) {
        CGFloat width = self.collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right;
        NSInteger numerator = width + self.minimumInteritemSpacing;
        NSInteger denominator = self.minimumInteritemSpacing + self.itemSize.width;
        NSInteger count = numerator / denominator;
        _columnCount = count;
        if (numerator % denominator) {
            if (count != 1) {
                self.minimumInteritemSpacing = (width - count * self.itemSize.width) / (CGFloat)(count - 1);
            }
        }
    }
    return _columnCount;
}

#pragma mark - Layout
- (void)prepareLayout {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexpath];
        [self.layoutAttributes addObject:attr];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attri = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger item = indexPath.item;
    NSInteger pageNumber = item / (self.rowCount * self.columnCount);
    NSInteger itemInPage = item % (self.rowCount * self.columnCount);
    NSInteger col = itemInPage % self.columnCount;
    NSInteger row = itemInPage / self.columnCount;
    
    CGFloat x = ROUND_SCALE(self.sectionInset.left + (self.itemSize.width + self.minimumInteritemSpacing) * col + pageNumber * self.collectionView.bounds.size.width);
    CGFloat y = ROUND_SCALE(self.sectionInset.top + (self.itemSize.height + self.minimumLineSpacing) * row);
    
    attri.frame = CGRectMake(x, y, ROUND_SCALE(self.itemSize.width), ROUND_SCALE(self.itemSize.height));
    return attri;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pageNumber = itemCount / (self.rowCount * self.columnCount);
    if (itemCount % (self.rowCount*self.columnCount)) {
        pageNumber += 1;
    }
    return CGSizeMake(pageNumber * self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
}




@end

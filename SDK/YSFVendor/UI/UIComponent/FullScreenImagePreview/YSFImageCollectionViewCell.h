//
//  YSFImageCollectionViewCell.h
//  YSFVendor
//
//  Created by liaosipei on 2019/4/1.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YSFGalleryItem;
@class YSFLargeImageView;


@protocol YSFImageCollectionViewCellDelegate <NSObject>

- (void)onTouchGalleryItem:(YSFGalleryItem *)item;
- (void)onLongPressGalleryItem:(YSFGalleryItem *)item;

@end


@interface YSFImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<YSFImageCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) YSFGalleryItem *itemData;

@property (nonatomic, strong) YSFLargeImageView *largeImageView;

@end

NS_ASSUME_NONNULL_END

//
//  YSFHorizontalPageLayout.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/24.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFHorizontalPageLayout : UICollectionViewLayout

@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGSize itemSize;

@end

NS_ASSUME_NONNULL_END

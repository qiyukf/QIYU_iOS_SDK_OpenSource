//
//  YSFGraphicPageView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YSFEmoticonItem;
@class YSFEmoticonPackage;
@class YSFEmoticonLayout;

@protocol YSFGraphicPageViewDelegate <NSObject>

- (void)selectGraphicItem:(YSFEmoticonItem *)selectItem;

@end


@interface YSFGraphicPageView : UIView

@property (nonatomic, weak) id<YSFGraphicPageViewDelegate> delegate;

- (instancetype)initWithPackageData:(YSFEmoticonPackage *)packageData layoutData:(YSFEmoticonLayout *)layoutData;

@end

NS_ASSUME_NONNULL_END

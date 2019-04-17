//
//  YSFEmojiPageView.h
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

@protocol YSFEmojiPageViewDelegate <NSObject>

- (void)selectEmojiItem:(YSFEmoticonItem *)selectItem;

@end


@interface YSFEmojiPageView : UIView

@property (nonatomic, weak) id<YSFEmojiPageViewDelegate> delegate;

- (instancetype)initWithPackageData:(YSFEmoticonPackage *)packageData layoutData:(YSFEmoticonLayout *)layoutData;

@end

NS_ASSUME_NONNULL_END

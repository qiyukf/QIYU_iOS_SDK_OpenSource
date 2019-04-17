//
//  YSFIconButton.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/2/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFIconButton : UIButton

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGFloat titleHeight;

@end

NS_ASSUME_NONNULL_END

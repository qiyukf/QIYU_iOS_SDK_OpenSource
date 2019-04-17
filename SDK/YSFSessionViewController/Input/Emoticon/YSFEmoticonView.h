//
//  YSFEmoticonView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YSFEmoticonItem;

@protocol YSFEmoticonViewDelegate <NSObject>

- (void)onTouchEmoticonSendButton:(id)sender;
- (void)selectEmoticonItem:(YSFEmoticonItem *)selectItem;

@end


@interface YSFEmoticonView : UIView

@property (nonatomic, weak) id<YSFEmoticonViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

//
//  YSFEmoticonTabView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YSFEmoticonPackage;

@protocol YSFEmoticonTabViewDelegate <NSObject>

- (void)tapSendButton:(id)sender;
- (void)selectEmoticonPackage:(YSFEmoticonPackage *)selectPackage indexPath:(NSIndexPath *)indexPath;

@end


@interface YSFEmoticonTabView : UIView

@property (nonatomic, weak) id<YSFEmoticonTabViewDelegate> delegate;

- (void)reloadEmoticonData:(NSArray *)emoticonData;
- (void)reloadView:(NSUInteger)curIndex;

@end

NS_ASSUME_NONNULL_END

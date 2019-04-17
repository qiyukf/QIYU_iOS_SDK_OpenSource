//
//  YSFEmoticonLoadingView.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/22.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YSFEmoticonLoadingType) {
    YSFEmoticonLoadingTypeLoading = 0,
    YSFEmoticonLoadingTypeFail,
    YSFEmoticonLoadingTypeNoData,
};


@protocol YSFEmoticonLoadingViewDelegate <NSObject>

- (void)tapRefreshButton:(id)sender;

@end


@interface YSFEmoticonLoadingView : UIView

@property (nonatomic, weak) id<YSFEmoticonLoadingViewDelegate> delegate;
@property (nonatomic, assign) YSFEmoticonLoadingType type;

@end

NS_ASSUME_NONNULL_END

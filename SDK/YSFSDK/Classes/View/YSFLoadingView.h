//
//  YSFLoadingView.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YSFLoadingType) {
    YSFLoadingTypeLoading = 0,
    YSFLoadingTypeFail,
    YSFLoadingTypeNoData,
};


@protocol YSFLoadingViewDelegate <NSObject>

- (void)tapRefreshButton:(id)sender;

@end


@interface YSFLoadingView : UIView

@property (nonatomic, weak) id<YSFLoadingViewDelegate> delegate;
@property (nonatomic, assign) YSFLoadingType type;

@end

NS_ASSUME_NONNULL_END

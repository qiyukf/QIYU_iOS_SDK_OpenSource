//
//  YSFMessageFormViewController.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSFMessageFormDelegate <NSObject>

- (void)onCloseMessageFormWithTitle:(NSString *)title resultData:(NSArray *)resultData;

@end


@interface YSFMessageFormViewController : UIViewController

@property (nonatomic, weak) id<YSFMessageFormDelegate> delegate;

- (instancetype)initWithShopId:(NSString *)shopId tip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END

//
//  YSFExtraCellLayoutConfig.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/10/8.
//  Copyright © 2018年 Netease. All rights reserved.
//

@class YSFMessageModel;
@protocol YSFMessageContentViewDelegate;

@protocol YSFExtraCellLayoutConfig <NSObject>

@optional
/**
 * @return 扩展视图大小
 */
- (CGSize)extraViewSize:(YSFMessageModel *)model;

/**
 * @return 扩展视图类名
 */
- (Class)extraViewClass;

/**
 * @return 扩展视图边距
 */
- (UIEdgeInsets)extraViewInsets:(YSFMessageModel *)model;

@end


@protocol YSFExtraViewParamConfig <NSObject>

@optional

@property (nonatomic, weak) id<YSFMessageContentViewDelegate> delegate;

- (void)configWithMsgModel:(YSFMessageModel *)msgModel;

@end

//
//  YSFDianZanViewLayoutConfig.h
//  QIYU_iOS_SDK_OpenSource
//
//  Created by majianming on 2018/9/19.
//
@class YSFMessageModel;
@protocol YSFMessageContentViewDelegate;

@protocol YSFDianZanViewLayoutConfig <NSObject>

@optional

/**
 点赞视图大小

 @return 大小
 */
- (CGSize)dianZanViewSize:(YSFMessageModel *)model;

/**
 点赞视图类名

 @return Class
 */
- (Class)dianZanViewClass;

/**
 点赞视图边距

 @return 边距
 */
- (UIEdgeInsets)dianZanViewInsets:(YSFMessageModel *)model;

@end

@protocol YSFDianZanViewParamConfig <NSObject>

@optional

@property (nonatomic, weak) id<YSFMessageContentViewDelegate> delegate;

- (void)configWithMsgModel:(YSFMessageModel*)msgModel;

@end

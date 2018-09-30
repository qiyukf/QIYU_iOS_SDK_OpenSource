//
//  YSFDianZanViewLayoutDefaultConfig.m
//  QIYU_iOS_SDK_OpenSource
//
//  Created by majianming on 2018/9/19.
//

#import "YSFDianZanViewLayoutDefaultConfig.h"

@implementation YSFDianZanViewLayoutDefaultConfig

/**
 点赞视图大小
 
 @return 大小
 */
- (CGSize)dianZanViewSize:(YSFMessageModel *)model
{
    return CGSizeZero;
}

/**
 点赞视图类名
 
 @return Class
 */
- (Class)dianZanViewClass
{
    return nil;
}

/**
 点赞视图边距
 
 @return 边距
 */
- (UIEdgeInsets)dianZanViewInsets:(YSFMessageModel *)model
{
    return UIEdgeInsetsZero;
}

@end

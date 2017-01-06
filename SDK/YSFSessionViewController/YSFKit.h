//
//  YSFKit.h
//  YSFKit
//
//  Created by amao on 8/14/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//


/**
 *  协议
 */
#import "YSFKitDataProvider.h"      //APP内容提供器


@interface YSFSessionUserInfo : NSObject
/**
 *  显示名
 */
@property (nonatomic,copy)   NSString *showName;


//如果avatarUrlString为nil，则显示头像图片
//如果avatarUrlString不为nil,则将头像图片当做占位图，当下载完成后显示头像url指定的图片。

/**
 *  头像url
 */
@property (nonatomic,copy)   NSString *avatarUrlString;

/**
 *  头像图片
 */
@property (nonatomic,strong) UIImage  *avatarImage;

@end


@interface YSFKit : NSObject

+ (instancetype)sharedKit;

/**
 *  内容提供者，由上层开发者注入。
 */
@property (nonatomic,strong)    id<YSFKitDataProvider> provider;

- (YSFSessionUserInfo *)infoByCustomer:(YSF_NIMMessage *)message;
- (YSFSessionUserInfo *)infoByService:(YSF_NIMMessage *)message;

/**
 *  YSFKit资源所在的bundle名称。
 */
@property (nonatomic,copy,readonly)      NSString *bundleName;

/**
 *  YSFKit自定义资源所在的bundle名称。
 */
@property (nonatomic,copy,readonly)      NSString *customBundleName;

@end





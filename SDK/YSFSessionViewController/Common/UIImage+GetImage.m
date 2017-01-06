//
//  UIImage+NIM.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "UIImage+GetImage.h"
#import "YSFKit.h"

@implementation UIImage (GetImage)

+ (UIImage *)ysf_imageInKit:(NSString *)imageName{
    NSString *name = [[[YSFKit sharedKit] customBundleName] stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageNamed:name];
    if (!image) {
        name = [[[YSFKit sharedKit] bundleName] stringByAppendingPathComponent:imageName];
        image = [UIImage imageNamed:name];
    }
    return image;
}


@end

//
//  UIImage+FileTransfer.h
//  YSFSessionViewController
//
//  Created by JackyYu on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FileTransfer)

+ (UIImage *)getFileIconWithDefaultIcon:(UIImage *)defaultIcon fileName:(NSString *)fileName;

@end

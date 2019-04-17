//
//  NIMImageContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFImageContentConfig.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFImageContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth {
    CGFloat imageWidth_min  = (cellWidth / 4.0);
    CGFloat imageHeight_min = (cellWidth / 4.0);
    CGFloat imageWidth_max  = (cellWidth - 184);
    CGFloat imageHeight_max = (cellWidth - 184);
    CGSize  contentSize = CGSizeMake(imageWidth_min, imageHeight_min);
    
    YSF_NIMImageObject *imageObject = (YSF_NIMImageObject *)[self.message messageObject];
    if (!CGSizeEqualToSize(imageObject.size, CGSizeZero)) {
        contentSize = [UIImage ysf_sizeWithImageOriginSize:imageObject.size
                                                   minSize:CGSizeMake(imageWidth_min, imageHeight_min)
                                                   maxSize:CGSizeMake(imageWidth_max, imageHeight_max)];
    }
    if (self.message.isPushMessageType && self.message.actionText.length) {
        contentSize.height += 44;
    }
    return contentSize;
}

- (NSString *)cellContent {
    return @"YSFSessionImageContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0,0,0,0);
}

@end

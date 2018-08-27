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
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat attachmentImageMinWidth  = (cellWidth / 4.0);
    CGFloat attachmentImageMinHeight = (cellWidth / 4.0);
    CGFloat attachmemtImageMaxWidth  = (cellWidth - 184);
    CGFloat attachmentImageMaxHeight = (cellWidth - 184);
    CGSize  contentSize = CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight);
    
    YSF_NIMImageObject *imageObject = (YSF_NIMImageObject*)[self.message messageObject];
    if (!CGSizeEqualToSize(imageObject.size, CGSizeZero))
    {
        contentSize = [UIImage ysf_sizeWithImageOriginSize:imageObject.size
                                                      minSize:CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight)
                                                      maxSize:CGSizeMake(attachmemtImageMaxWidth, attachmentImageMaxHeight )];
    }
    if (self.message.isPushMessageType
        && self.message.actionText.length) {
        contentSize.height += 44;
    }
    
    return contentSize;
}

- (NSString *)cellContent
{
    return @"YSFSessionImageContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(0,0,0,0);
}
@end

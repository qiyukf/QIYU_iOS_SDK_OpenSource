//
//  NIMVideoContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFVideoContentConfig.h"

@implementation YSFVideoContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat attachmentImageMinWidth  = (cellWidth / 4.0);
    CGFloat attachmentImageMinHeight = (cellWidth / 4.0);
    CGFloat attachmemtImageMaxWidth  = (cellWidth - 184);
    CGFloat attachmentImageMaxHeight = (cellWidth - 184);
    CGSize contentSize = CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight);
    
    YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject*)[self.message messageObject];
    if (!CGSizeEqualToSize(videoObject.coverSize, CGSizeZero)) {
        //有封面就直接拿封面大小
        contentSize = [UIImage ysf_sizeWithImageOriginSize:videoObject.coverSize
                                                      minSize:CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight)
                                                      maxSize:CGSizeMake(attachmemtImageMaxWidth, attachmentImageMaxHeight)];
    }
    return contentSize;
}

- (NSString *)cellContent
{
    return @"YSFSessionVideoContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(3,3,3,8) : UIEdgeInsetsMake(3,8,3,3);
}
@end

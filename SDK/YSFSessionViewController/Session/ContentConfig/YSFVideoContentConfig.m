//
//  NIMVideoContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFVideoContentConfig.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFVideoContentConfig

- (CGSize)contentSize:(CGFloat)cellWidth {
    CGFloat attachmentImageMinWidth  = (cellWidth / 4.0);
    CGFloat attachmentImageMinHeight = (cellWidth / 4.0);
    CGFloat attachmemtImageMaxWidth  = (cellWidth - 184);
    CGFloat attachmentImageMaxHeight = (cellWidth - 184);
    CGSize contentSize = CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight);
    
    YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)[self.message messageObject];
    if (!CGSizeEqualToSize(videoObject.coverSize, CGSizeZero)) {
        contentSize = [UIImage ysf_sizeWithImageOriginSize:videoObject.coverSize
                                                   minSize:CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight)
                                                   maxSize:CGSizeMake(attachmemtImageMaxWidth, attachmentImageMaxHeight)];
    }
    if (self.message.isPushMessageType
        && self.message.actionText.length) {
        contentSize.height += 44;
    }
    return contentSize;
}

- (NSString *)cellContent {
    return @"YSFSessionVideoContentView";
}

- (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0,0,0,0);
}
@end

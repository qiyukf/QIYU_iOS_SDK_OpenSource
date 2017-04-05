//
//  NIMFileContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFFileContentConfig.h"

@implementation YSFFileContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    return CGSizeMake(225, 85);
}

- (NSString *)cellContent
{
    return @"YSFSessionFileTransContentView";
}


- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0, 0, 0, 0) : UIEdgeInsetsMake(0, 0, 0, 0);
}
@end

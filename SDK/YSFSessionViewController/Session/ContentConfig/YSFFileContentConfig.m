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
    return CGSizeMake(220, 110);
}

- (NSString *)cellContent
{
    return @"YSFSessionFileTransContentView";
}


- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(3,3,3,8) : UIEdgeInsetsMake(3,8,3,3);
}
@end

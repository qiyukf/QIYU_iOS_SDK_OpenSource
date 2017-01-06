//
//  NIMInputEmoticonButton.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputEmoticonButton.h"
#import "YSFInputEmoticonManager.h"

@implementation YSFInputEmoticonButton

+ (YSFInputEmoticonButton*)iconButtonWithData:(YSFInputEmoticon*)data catalogID:(NSString*)catalogID delegate:( id<YSFEmoticonButtonTouchDelegate>)delegate{
    YSFInputEmoticonButton* icon = [[YSFInputEmoticonButton alloc] init];
    [icon addTarget:icon action:@selector(onIconSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage ysf_fetchImage:data.filename];
    
    icon.emoticonData    = data;
    icon.catalogID              = catalogID;
    icon.userInteractionEnabled = YES;
    icon.exclusiveTouch         = YES;
    icon.contentMode            = UIViewContentModeScaleToFill;
    icon.delegate               = delegate;
    [icon setImage:image forState:UIControlStateNormal];
    [icon setImage:image forState:UIControlStateHighlighted];
    return icon;
}



- (void)onIconSelected:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectedEmoticon:catalogID:)])
    {
        [self.delegate selectedEmoticon:self.emoticonData catalogID:self.catalogID];
    }
}

@end

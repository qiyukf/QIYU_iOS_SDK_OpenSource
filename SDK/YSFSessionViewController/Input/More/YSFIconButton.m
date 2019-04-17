//
//  YSFIconButton.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/2/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFIconButton.h"
#import "YSFTools.h"

@interface YSFIconButton ()

@end


@implementation YSFIconButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = YSFColorFromRGB(0x333333);
        [self addSubview:_label];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _label.text = title;
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    [self setImage:normalImage forState:UIControlStateNormal];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    _highlightedImage = highlightedImage;
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)setFrame:(CGRect)frame {
    if (CGRectEqualToRect(self.frame, frame)) {
        return;
    }
    [super setFrame:frame];
    self.label.font = [UIFont systemFontOfSize:floorf(self.titleHeight - 1.0)];
    self.label.frame = CGRectMake(0, CGRectGetHeight(self.frame) - self.titleHeight, CGRectGetWidth(self.frame), self.titleHeight);
    
    CGFloat space = ROUND_SCALE((CGRectGetWidth(self.frame) - self.imageSize.width) / 2);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, space, CGRectGetHeight(self.frame) - self.imageSize.height, space);
}

@end

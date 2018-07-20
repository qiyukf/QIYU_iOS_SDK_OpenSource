#import "YSFHiddenContentConfig.h"


@implementation YSFHiddenContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    return CGSizeZero;
}

- (NSString *)cellContent
{
    return @"YSFSessionHiddenContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

@end

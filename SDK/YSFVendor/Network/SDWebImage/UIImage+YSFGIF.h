/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "YSFWebImageCompat.h"

@interface UIImage (GIF)

/**
 *  Compatibility method - creates an animated UIImage from an NSData, it will only contain the 1st frame image
 */
+ (UIImage *)ysf_animatedGIFWithData:(NSData *)data;

/**
 *  Checks if an UIImage instance is a GIF. Will use the `images` array
 */
- (BOOL)ysf_isGIF;

@end

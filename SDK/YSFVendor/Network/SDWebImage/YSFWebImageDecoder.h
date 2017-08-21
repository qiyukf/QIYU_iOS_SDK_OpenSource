/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) james <https://github.com/mystcolor>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "YSFWebImageCompat.h"

@interface UIImage (ForceDecode)

+ (nullable UIImage *)ysf_decodedImageWithImage:(nullable UIImage *)image;

+ (nullable UIImage *)ysf_decodedAndScaledDownImageWithImage:(nullable UIImage *)image;

@end

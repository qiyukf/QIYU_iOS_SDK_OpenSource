/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef YSF_WEBP

#import "YSFWebImageCompat.h"

@interface UIImage (WebP)

+ (nullable UIImage *)ysf_imageWithWebPData:(nullable NSData *)data;

@end

#endif

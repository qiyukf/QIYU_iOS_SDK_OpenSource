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

/**
 * Get the current WebP image loop count, the default value is 0.
 * For static WebP image, the value is 0.
 * For animated WebP image, 0 means repeat the animation indefinitely.
 * Note that because of the limitations of categories this property can get out of sync
 * if you create another instance with CGImage or other methods.
 * @return WebP image loop count
 * @deprecated use `ysf_imageLoopCount` instead.
 */
- (NSInteger)ysf_webpLoopCount __deprecated_msg("Method deprecated. Use `ysf_imageLoopCount` in `UIImage+MultiFormat.h`");

+ (nullable UIImage *)ysf_imageWithWebPData:(nullable NSData *)data;

@end

#endif

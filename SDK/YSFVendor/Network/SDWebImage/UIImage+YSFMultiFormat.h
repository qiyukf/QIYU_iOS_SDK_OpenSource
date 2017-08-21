/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "YSFWebImageCompat.h"
#import "NSData+YSFImageContentType.h"

@interface UIImage (MultiFormat)

+ (nullable UIImage *)ysf_imageWithData:(nullable NSData *)data;
- (nullable NSData *)ysf_imageData;
- (nullable NSData *)ysf_imageDataAsFormat:(YSFImageFormat)imageFormat;

@end

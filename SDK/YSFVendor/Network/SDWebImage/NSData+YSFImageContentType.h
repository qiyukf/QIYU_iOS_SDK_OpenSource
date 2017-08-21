/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "YSFWebImageCompat.h"

typedef NS_ENUM(NSInteger, YSFImageFormat) {
    YSFImageFormatUndefined = -1,
    YSFImageFormatJPEG = 0,
    YSFImageFormatPNG,
    YSFImageFormatGIF,
    YSFImageFormatTIFF,
    YSFImageFormatWebP
};

@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (YSFImageFormat)ysf_imageFormatForImageData:(nullable NSData *)data;

@end

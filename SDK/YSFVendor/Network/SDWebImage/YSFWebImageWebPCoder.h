/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef YSF_WEBP

#import <Foundation/Foundation.h>
#import "YSFWebImageCoder.h"

/**
 Built in coder that supports WebP and animated WebP
 */
@interface YSFWebImageWebPCoder : NSObject <YSFWebImageProgressiveCoder>

+ (nonnull instancetype)sharedCoder;

@end

#endif

//
//  YSFCoreGraphicsUtils.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 7/18/10.
//  Copyright 2010 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <tgmath.h>

/**
 Various CoreGraphics-related utility functions
 */

/**
 Promotes value to CGFloat type.
 */
#define CGFloat_(__x)	((CGFloat) (__x))

/**
 Calculates a size that fits an original size into a different size preserving the aspect ratio.
 */
CGSize YSFCGSizeThatFitsKeepingAspectRatio(CGSize originalSize, CGSize sizeToFit);

/**
 Calculates a size that fits an original size into a different size preserving the aspect ratio and filling the target size.
 */
CGSize YSFCGSizeThatFillsKeepingAspectRatio(CGSize originalSize, CGSize sizeToFit);

/**
 Replacement for buggy CGSizeMakeWithDictionaryRepresentation
 @param dict The dictionary containing an encoded `CGSize`
 @param size The `CGSize` to decode from the dictionary
 @see http://www.cocoanetics.com/2012/09/radar-cgrectmakewithdictionaryrepresentation/
 */
BOOL YSFCGSizeMakeWithDictionaryRepresentation(NSDictionary *dict, CGSize *size);

/**
 Replacement for buggy CGSizeCreateDictionaryRepresentation
 @param size The `CGSize` to encode in the returned dictionary
 @see http://www.cocoanetics.com/2012/09/radar-cgrectmakewithdictionaryrepresentation/
 */
NSDictionary *YSFCGSizeCreateDictionaryRepresentation(CGSize size);

/**
 Replacement for buggy CGRectMakeWithDictionaryRepresentation
 @param dict The dictionary containing an encoded `CGRect`
 @param rect The `CGRect` to decode from the dictionary
 @see http://www.cocoanetics.com/2012/09/radar-cgrectmakewithdictionaryrepresentation/
 */
BOOL YSFCGRectMakeWithDictionaryRepresentation(NSDictionary *dict, CGRect *rect);

/**
 Replacement for buggy CGRectCreateDictionaryRepresentation
 @param rect The `CGRect` to encode in the returned dictionary
 @see http://www.cocoanetics.com/2012/09/radar-cgrectmakewithdictionaryrepresentation/
 */
NSDictionary *YSFCGRectCreateDictionaryRepresentation(CGRect rect);

/**
 Convenience method to find the center of a CGRect. Uses CGRectGetMidX and CGRectGetMidY.
 @returns The point which is the center of rect.
 */
CGPoint YSFCGRectCenter(CGRect rect);

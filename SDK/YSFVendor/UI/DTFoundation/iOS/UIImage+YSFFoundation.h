//
//  UIImage+YSFFoundation.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 3/8/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Methods to help with working with images.
 */
@interface UIImage (YSFFoundation)

/**
 @name Generating Images
 */

/**
 Creates an image filled with a solid color
 @param color The solid color that fills the image
 @param size The size of the image
 @returns The image filled with given color and given size
 */
+ (UIImage *)ysf_imageWithSolidColor:(UIColor *)color size:(CGSize)size;


/**
 Creates an image filled with a tint color using the receiver as image mask. The resulting image ignores the receiver's color values and instead uses the alpha values combined with the passed color.
 @param color The color to use for tinting
 @returns A new image
 */
- (UIImage *)ysf_imageMaskedAndTintedWithColor:(UIColor *)color;

/**
 @name Loading from RemoteURLs
 */


/**
 Creates and returns an image object synchronously by loading the image data from the specified URL and optionally caching it.
 
 Useful values for cachePolicy are:
 
 - NSURLRequestUseProtocolCachePolicy (default)
 - NSURLRequestReloadIgnoringLocalCacheData
 - NSURLRequestReturnCacheDataElseLoad
 - NSURLRequestReturnCacheDataDontLoad
 
 @param URL The URL to load the image from
 @param cachePolicy The cache policy to apply.
 @param error An optional output parameter to return an error if the loading fails
 @returns The image object for the specified URL, or nil if the method could not load the specified image.
 */
+ (UIImage *)ysf_imageWithContentsOfURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy error:(NSError **)error;


 /**
 @name Drawing
 */
 
/**
 Mimicks the way images are drawn differently by UIImageView based on the set content mode.
 @param rect The rectangle to drawn in
 @param contentMode The content mode. Note that UIViewContentModeRedraw is treated the same as UIViewContentModeScaleToFill.
 */
- (void)ysf_drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode;

/**
 @name Working with Tiles
 */
 
/**
 Cuts out a tile at the given row and column
 
 @param column The index of the column
 @param columns The total number of columns
 @param row The index of the row
 @param rows The total number of rows
 @returns The resulting image
 */
- (UIImage *)ysf_tileImageAtColumn:(NSUInteger)column ofColumns:(NSUInteger)columns row:(NSUInteger)row ofRows:(NSUInteger)rows;

/**
 Cuts out a tile at the given clip rect relative to the bounds
 
 @param clipRect The clipping rect to extract
 @param bounds The bounds to which the clipRect is relative to
 @param scale The image scale
 @returns The resulting image
 */
- (UIImage *)ysf_tileImageInClipRect:(CGRect)clipRect inBounds:(CGRect)bounds scale:(CGFloat)scale;


/**
 @name Modifying Images
 */

/**
 Resizes the receiver to the given size.
 
 @param newSize The target image size
 @returns The resulting image
 */
- (UIImage *)ysf_imageScaledToSize:(CGSize)newSize;

@end

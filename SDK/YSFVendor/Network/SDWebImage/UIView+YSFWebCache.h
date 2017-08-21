/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "YSFWebImageCompat.h"

#if YSF_UIKIT || YSF_MAC

#import "YSFWebImageManager.h"

typedef void(^YSFSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (WebCache)

/**
 * Get the current image URL.
 *
 * Note that because of the limitations of categories this property can get out of sync
 * if you use setImage: directly.
 */
- (nullable NSURL *)ysf_imageURL;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see YSFWebImageOptions for the possible values.
 * @param operationKey   A string to be used as the operation key. If nil, will use the class name
 * @param setImageBlock  Block used for custom set image code
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)ysf_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(YSFWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable YSFSetImageBlock)setImageBlock
                          progress:(nullable YSFWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable YSFExternalCompletionBlock)completedBlock;

/**
 * Cancel the current download
 */
- (void)ysf_cancelCurrentImageLoad;

#if YSF_UIKIT

#pragma mark - Activity indicator

/**
 *  Show activity UIActivityIndicatorView
 */
- (void)ysf_setShowActivityIndicatorView:(BOOL)show;

/**
 *  set desired UIActivityIndicatorViewStyle
 *
 *  @param style The style of the UIActivityIndicatorView
 */
- (void)ysf_setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (BOOL)ysf_showActivityIndicatorView;
- (void)ysf_addActivityIndicator;
- (void)ysf_removeActivityIndicator;

#endif

@end

#endif

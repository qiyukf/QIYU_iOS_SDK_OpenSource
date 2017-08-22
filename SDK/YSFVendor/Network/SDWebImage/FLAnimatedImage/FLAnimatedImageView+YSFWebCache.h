/*
 * This file is part of the YSFWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "YSFWebImageCompat.h"

#if YSF_UIKIT

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
#import <FLAnimatedImage/FLAnimatedImage.h>
#else
#import "YSFAnimatedImageView.h"
#endif

#import "YSFWebImageManager.h"


/**
 *  A category for the FLAnimatedImage imageView class that hooks it to the YSFWebImage system.
 *  Very similar to the base class category (UIImageView (WebCache))
 */
@interface YSFAnimatedImageView (WebCache)

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 * Uses a placeholder until the request finishes.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 * Uses a placeholder until the request finishes.
 *
 *  @param url         The url for the image.
 *  @param placeholder The image to be set initially, until the image request finishes.
 *  @param options     The options to use when downloading the image. @see YSFWebImageOptions for the possible values.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(YSFWebImageOptions)options;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 *
 *  @param url            The url for the image.
 *  @param completedBlock A block called when operation has been completed. This block has no return value
 *                        and takes the requested UIImage as first parameter. In case of error the image parameter
 *                        is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                        indicating if the image was retrieved from the local cache or from the network.
 *                        The fourth parameter is the original image url.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
                 completed:(nullable YSFExternalCompletionBlock)completedBlock;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 * Uses a placeholder until the request finishes.
 *
 *  @param url            The url for the image.
 *  @param placeholder    The image to be set initially, until the image request finishes.
 *  @param completedBlock A block called when operation has been completed. This block has no return value
 *                        and takes the requested UIImage as first parameter. In case of error the image parameter
 *                        is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                        indicating if the image was retrieved from the local cache or from the network.
 *                        The fourth parameter is the original image url.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable YSFExternalCompletionBlock)completedBlock;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 * Uses a placeholder until the request finishes.
 *
 *  @param url            The url for the image.
 *  @param placeholder    The image to be set initially, until the image request finishes.
 *  @param options        The options to use when downloading the image. @see YSFWebImageOptions for the possible values.
 *  @param completedBlock A block called when operation has been completed. This block has no return value
 *                        and takes the requested UIImage as first parameter. In case of error the image parameter
 *                        is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                        indicating if the image was retrieved from the local cache or from the network.
 *                        The fourth parameter is the original image url.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(YSFWebImageOptions)options
                 completed:(nullable YSFExternalCompletionBlock)completedBlock;

/**
 * Load the image at the given url (either from cache or download) and load it in this imageView. It works with both static and dynamic images
 * The download is asynchronous and cached.
 * Uses a placeholder until the request finishes.
 *
 *  @param url            The url for the image.
 *  @param placeholder    The image to be set initially, until the image request finishes.
 *  @param options        The options to use when downloading the image. @see YSFWebImageOptions for the possible values.
 *  @param progressBlock  A block called while image is downloading
 *                        @note the progress block is executed on a background queue
 *  @param completedBlock A block called when operation has been completed. This block has no return value
 *                        and takes the requested UIImage as first parameter. In case of error the image parameter
 *                        is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                        indicating if the image was retrieved from the local cache or from the network.
 *                        The fourth parameter is the original image url.
 */
- (void)ysf_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(YSFWebImageOptions)options
                  progress:(nullable YSFWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable YSFExternalCompletionBlock)completedBlock;

@end

#endif

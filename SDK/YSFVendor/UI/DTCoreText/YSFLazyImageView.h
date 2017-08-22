//
//  YSFLazyImageView.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 5/20/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "YSFWeakSupport.h"
#import "YSFAttributedTextContentView.h"

@class YSFLazyImageView;

// Notifications
extern NSString * const YSFLazyImageViewWillStartDownloadNotification;
extern NSString * const YSFLazyImageViewDidFinishDownloadNotification;

/**
 Protocol for delegates of <YSFLazyImageView> to inform them about the downloaded image dimensions.
 */
@protocol YSFLazyImageViewDelegate <NSObject>
@optional

/**
 Method that informs the delegate about the image size so that it can re-layout text.
 @param lazyImageView The image view
 @param size The image size that is now known
 */
- (void)lazyImageView:(YSFLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size;
@end

/**
 This `UIImageView` subclass lazily loads an image from a URL and informs a delegate once the size of the image is known.
 */

@interface YSFLazyImageView : UIImageView

/**
 @name Providing Content
 */

/**
 The URL of the remote image
 */
@property (nonatomic, strong) NSURL *url;

/**
 The URL Request that is to be used for downloading the image. If this is left `nil` the a new URL Request will be created
 */
@property (nonatomic, strong) NSMutableURLRequest *urlRequest;

/**
 The YSFAttributedTextContentView used to display remote images with YSFAttributedTextCell
 */
@property (nonatomic, YSF_WEAK_PROPERTY) YSFAttributedTextContentView *contentView;

/**
 @name Getting Information
 */

/**
 Set to `YES` to support progressive display of progressive downloads
 */
@property (nonatomic, assign) BOOL shouldShowProgressiveDownload;

/**
 The delegate, conforming to <YSFLazyImageViewDelegate>, to inform when the image dimensions were determined
 */
@property (nonatomic, YSF_WEAK_PROPERTY) id<YSFLazyImageViewDelegate> delegate;


/**
 @name Cancelling Download
*/

/**
 Cancels the image downloading
 */
- (void)cancelLoading;

@end

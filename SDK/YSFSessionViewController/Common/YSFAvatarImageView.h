//
//  NIMAvatarImageView.h
//  YSFKit
//
//  Created by chris on 15/2/10.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFWebImageCompat.h"
#import "YSFWebImageManager.h"
#import "NIMSDK.h"

@interface YSFAvatarImageView : UIControl
@property (nonatomic,strong)    UIImage *image;
@property (nonatomic,assign)    BOOL    clipPath;

- (void)setAvatarBySession:(BOOL)customerOrService message:(YSF_NIMMessage*)message;
@end


@interface YSFAvatarImageView (SDWebImageCache)
- (NSURL *)ysf_imageURL;

- (void)ysf_setImageWithURL:(NSURL *)url;
- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options;
- (void)ysf_setImageWithURL:(NSURL *)url completed:(YSFInternalCompletionBlock)completedBlock;
- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(YSFInternalCompletionBlock)completedBlock;
- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options completed:(YSFInternalCompletionBlock)completedBlock;
- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options progress:(YSFWebImageDownloaderProgressBlock)progressBlock completed:(YSFInternalCompletionBlock)completedBlock;
- (void)ysf_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options progress:(YSFWebImageDownloaderProgressBlock)progressBlock completed:(YSFInternalCompletionBlock)completedBlock;
- (void)ysf_cancelCurrentImageLoad;
- (void)ysf_cancelCurrentAnimationImagesLoad;
@end

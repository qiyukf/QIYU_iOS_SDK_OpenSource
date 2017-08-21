//
//  NIMAvatarImageView.m
//  YSFKit
//
//  Created by chris on 15/2/10.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFAvatarImageView.h"
#import "objc/runtime.h"
#import "YSFKit.h"


static char imageURLKey;


@interface YSFAvatarImageView()
@end

@implementation YSFAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.geometryFlipped = YES;
        self.clipPath = YES;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.geometryFlipped = YES;
        self.clipPath = YES;
    }
    return self;
}


- (void)setImage:(UIImage *)image
{
    if (_image != image)
    {
        _image = image;
        [self setNeedsDisplay];
    }
}


- (CGPathRef)path
{
    return [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                       cornerRadius:CGRectGetWidth(self.bounds) / 2] CGPath];
}


#pragma mark Draw
- (void)drawRect:(CGRect)rect
{
    if (!self.ysf_frameWidth || !self.ysf_frameHeight) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    if (_clipPath)
    {
        CGContextAddPath(context, [self path]);
        CGContextClip(context);
    }
    UIImage *image = _image;
    if (image && image.size.height && image.size.width)
    {
        //ScaleAspectFill模式
        CGPoint center   = CGPointMake(self.ysf_frameWidth * .5f, self.ysf_frameHeight * .5f);
        //哪个小按哪个缩
        CGFloat scaleW   = image.size.width  / self.ysf_frameWidth;
        CGFloat scaleH   = image.size.height / self.ysf_frameHeight;
        CGFloat scale    = scaleW < scaleH ? scaleW : scaleH;
        CGSize  size     = CGSizeMake(image.size.width / scale, image.size.height / scale);
        CGRect  drawRect = YSFKit_CGRectWithCenterAndSize(center, size);
        CGContextDrawImage(context, drawRect, image.CGImage);
        
    }
    CGContextRestoreGState(context);
}

CGRect YSFKit_CGRectWithCenterAndSize(CGPoint center, CGSize size){
    return CGRectMake(center.x - (size.width/2), center.y - (size.height/2), size.width, size.height);
}

- (void)setAvatarBySession:(BOOL)customerOrService message:(YSF_NIMMessage*)message;
{
    YSFSessionUserInfo *info  = nil;
    if (customerOrService) {
        info = [[YSFKit sharedKit] infoByCustomer:message];
    }
    else {
        info = [[YSFKit sharedKit] infoByService:message];
    }
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    UIImage *placeholder = info.avatarImage ? : [UIImage ysf_imageInKit:@"icon_default_avatar"];
    [self ysf_setImageWithURL:url placeholderImage:placeholder];
}

@end


@implementation YSFAvatarImageView (SDWebImageCache)

- (void)ysf_setImageWithURL:(NSURL *)url {
    [self ysf_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self ysf_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options {
    [self ysf_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)ysf_setImageWithURL:(NSURL *)url completed:(YSFInternalCompletionBlock)completedBlock {
    [self ysf_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(YSFInternalCompletionBlock)completedBlock {
    [self ysf_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options completed:(YSFInternalCompletionBlock)completedBlock {
    [self ysf_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)ysf_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options progress:(YSFWebImageDownloaderProgressBlock)progressBlock completed:(YSFInternalCompletionBlock)completedBlock {
    [self ysf_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & YSFWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak __typeof(self)wself = self;
        YSFWebImageDownloadToken *operation = [YSFWebImageManager.sharedManager loadImageWithURL:url options:options progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, YSFImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!wself) return;
            if (image && (options & YSFWebImageAvoidAutoSetImage) && completedBlock)
            {
                completedBlock(image, data, error, cacheType, finished, imageURL);
                return;
            }
            else if (image) {
                wself.image = image;
                [wself setNeedsLayout];
            } else {
                if ((options & YSFWebImageDelayPlaceholder)) {
                    wself.image = placeholder;
                    [wself setNeedsLayout];
                }
            }
            if (completedBlock && finished) {
                completedBlock(image, data, error, cacheType, finished, imageURL);
            }
        }];
        [self ysf_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:YSFWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, nil, error, YSFImageCacheTypeNone, NO, nil);
            }
        });
    }
}

- (void)ysf_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(YSFWebImageOptions)options progress:(YSFWebImageDownloaderProgressBlock)progressBlock completed:(YSFInternalCompletionBlock)completedBlock {
    NSString *key = [[YSFWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[YSFImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self ysf_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];
}

- (NSURL *)ysf_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}


- (void)ysf_cancelCurrentImageLoad {
    [self ysf_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)ysf_cancelCurrentAnimationImagesLoad {
    [self ysf_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}


@end

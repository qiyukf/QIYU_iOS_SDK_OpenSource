//
//  NIMAudioContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFStaticUnionContentConfig.h"
#import "NSDictionary+YSFJson.h"
#import "NIMSDK.h"
#import "KFAudioToTextHandler.h"
#import "YSFApiDefines.h"
#import "YSFStaticUnion.h"
#import "UIImageView+YSFWebCache.h"
#import "NSString+FileTransfer.h"
#import "YSFCoreText.h"
#import "NSAttributedString+YSF.h"


@implementation YSFStaticUnionContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth
{
    CGFloat msgContentMaxWidth    = (cellWidth - 112);
    __block CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.message.messageObject;
    YSFStaticUnion *staticUnion = (YSFStaticUnion *)object.attachment;
    
    for (YSFLinkItem *item in staticUnion.linkItems) {
        if ([item.type isEqualToString:YSFApiKeyText]) {
            offsetY += 13;
            UILabel *content = [UILabel new];
            content.font = [UIFont systemFontOfSize:16];
            content.numberOfLines = 0;
            content.text = item.label;
            content.ysf_frameWidth = msgContentMaxWidth - 33;
            [content sizeToFit];
            offsetY += content.ysf_frameHeight;
        }
        else if ([item.type isEqualToString:YSFApiKeyImage]) {
            offsetY += 13;

            if (item.imageUrl.length > 0) {

                UIImageView *imageView = [UIImageView new];
                imageView.frame = CGRectMake(18, offsetY, msgContentMaxWidth - 33, 90);
                
                NSURL *url = nil;
                if (item.imageUrl) {
                    url = [NSURL URLWithString:item.imageUrl];
                }
                if (url) {
                    NSString *key = [[YSFWebImageManager sharedManager] cacheKeyForURL:url];
                    UIImage *image = [[YSFImageCache sharedImageCache] imageFromDiskCacheForKey:key];
                    if (image) {
                        CGFloat width = image.size.width;
                        CGFloat height = image.size.height;
                        if (image.size.width > msgContentMaxWidth - 33) {
                            width = msgContentMaxWidth - 33;
                            height = (height/image.size.width) * width;
                        }
                        imageView.ysf_frameWidth = width;
                        imageView.ysf_frameHeight = height;
                    }
                }
                
                offsetY += imageView.ysf_frameHeight;
            }
        }
        else if ([item.type isEqualToString:YSFApiKeyLink]) {
            offsetY += 13 + 34;
        }
        else if ([item.type isEqualToString:YSFApiKeyRichText]) {
            offsetY += 13;
            
            NSAttributedString *attributedString = [item.label ysf_attributedString:self.message.isOutgoingMsg];
            CGSize size = [attributedString intrinsicContentSizeWithin:CGSizeMake(CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN)];
            if (size.width > msgContentMaxWidth) {
                size = [attributedString intrinsicContentSizeWithin:CGSizeMake(msgContentMaxWidth - 33, CGFLOAT_HEIGHT_UNKNOWN)];
            }
            
            offsetY += size.height;
        }
    }
    
    offsetY += 13;
    
    return CGSizeMake(msgContentMaxWidth, offsetY);
}

- (NSString *)cellContent
{
    return @"YSFStaticUnionContentView";
}

- (UIEdgeInsets)contentViewInsets
{
    return self.message.isOutgoingMsg ? UIEdgeInsetsMake(0,0,0,0) : UIEdgeInsetsMake(0,0,0,0);
}
@end

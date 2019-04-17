//
//  YSFGraphicCell.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFGraphicCell.h"
#import "YSFEmoticonDataManager.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFTools.h"

@interface YSFGraphicCell ()

@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation YSFGraphicCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _placeHolder = [UIImage ysf_imageInKit:@"icon_placeholder_large"];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)setItemData:(YSFEmoticonItem *)itemData {
    _itemData = itemData;
    if (itemData.type == YSFEmoticonTypeDefaultEmoji) {
        [_imageView ysf_setImageWithURL:nil placeholderImage:[UIImage ysf_fetchImage:itemData.filePath]];
    } else {
        __weak typeof(self) weakSelf = self;
        [_imageView ysf_setImageWithURL:[NSURL URLWithString:itemData.fileURL]
                       placeholderImage:self.placeHolder
                              completed:^(UIImage * _Nullable image, NSError * _Nullable error, YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                  if (!error && image) {
                                      
                                  } else {
                                      weakSelf.imageView.image = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                      weakSelf.itemData.type = YSFEmoticonTypeNone;
                                  }
                              }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.bounds) - YSFEmoticon_kGrapgicSize) / 2),
                                  ROUND_SCALE((CGRectGetHeight(self.bounds) - YSFEmoticon_kGrapgicSize) / 2),
                                  YSFEmoticon_kGrapgicSize,
                                  YSFEmoticon_kGrapgicSize);
}

@end

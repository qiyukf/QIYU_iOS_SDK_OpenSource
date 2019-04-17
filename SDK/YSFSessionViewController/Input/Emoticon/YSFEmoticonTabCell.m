//
//  YSFEmoticonTabCell.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonTabCell.h"
#import "YSFEmoticonDataManager.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFTools.h"


@interface YSFEmoticonTabCell ()

@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) UIImageView *coverImageView;

@end


@implementation YSFEmoticonTabCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _placeHolder = [UIImage ysf_imageInKit:@"icon_placeholder_small"];
        
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self.contentView addSubview:_seperatorLine];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.backgroundColor = [UIColor clearColor];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_coverImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = YSFColorFromRGB(0xf7f7f7);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setPackageData:(YSFEmoticonPackage *)packageData {
    _packageData = packageData;
    if (packageData.type == YSFEmoticonTypeDefaultEmoji) {
        [_coverImageView ysf_setImageWithURL:nil placeholderImage:[UIImage ysf_fetchImage:packageData.coverPressName]];
    } else {
        [_coverImageView ysf_setImageWithURL:[NSURL URLWithString:packageData.coverURL]
                            placeholderImage:self.placeHolder
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                       if (!error && image) {
                                           
                                       }
                                   }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
    _seperatorLine.frame = CGRectMake(CGRectGetWidth(self.frame) - lineWidth, 0, lineWidth, CGRectGetHeight(self.frame));
    _coverImageView.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.bounds) - YSFEmoticon_kTabItemSize) / 2),
                                       ROUND_SCALE((CGRectGetHeight(self.bounds) - YSFEmoticon_kTabItemSize) / 2),
                                       YSFEmoticon_kTabItemSize,
                                       YSFEmoticon_kTabItemSize);
}

@end

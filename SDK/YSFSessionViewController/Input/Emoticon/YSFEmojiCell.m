//
//  YSFEmojiCell.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmojiCell.h"
#import "YSFEmoticonDataManager.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFTools.h"

@interface YSFEmojiCell ()

@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation YSFEmojiCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _placeHolder = [UIImage ysf_imageInKit:@"icon_placeholder_small"];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.userInteractionEnabled = NO;
        UIImage *imageNormal = [UIImage ysf_fetchImage:[[YSFEmoticonDataManager sharedManager].emojiPath stringByAppendingString:@"/emoji_del_normal"]];
        UIImage *imagePressed = [UIImage ysf_fetchImage:[[YSFEmoticonDataManager sharedManager].emojiPath stringByAppendingString:@"/emoji_del_pressed"]];
        [_deleteButton setImage:imageNormal forState:UIControlStateNormal];
        [_deleteButton setImage:imagePressed forState:UIControlStateHighlighted];
        [self.contentView addSubview:_deleteButton];
    }
    return self;
}

- (void)setItemData:(YSFEmoticonItem *)itemData {
    _itemData = itemData;
    if (itemData.type == YSFEmoticonTypeDefaultEmoji) {
        _imageView.hidden = NO;
        _deleteButton.hidden = YES;
        [_imageView ysf_setImageWithURL:nil placeholderImage:[UIImage ysf_fetchImage:itemData.filePath]];
    } else if (itemData.type == YSFEmoticonTypeCustomEmoji) {
        _imageView.hidden = NO;
        _deleteButton.hidden = YES;
        [_imageView ysf_setImageWithURL:[NSURL URLWithString:itemData.fileURL]
                       placeholderImage:self.placeHolder
                              completed:^(UIImage * _Nullable image, NSError * _Nullable error, YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                  if (!error && image) {
                                      
                                  }
                              }];
    } else if (itemData.type == YSFEmoticonTypeDelete) {
        _imageView.hidden = YES;
        _deleteButton.hidden = NO;
    } else {
        _imageView.hidden = YES;
        _deleteButton.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.bounds) - YSFEmoticon_kEmojiSize) / 2),
                                  ROUND_SCALE((CGRectGetHeight(self.bounds) - YSFEmoticon_kEmojiSize) / 2),
                                  YSFEmoticon_kEmojiSize,
                                  YSFEmoticon_kEmojiSize);
    _deleteButton.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.bounds) - YSFEmoticon_kDeleteWidth) / 2),
                                     ROUND_SCALE((CGRectGetHeight(self.bounds) - YSFEmoticon_kDeleteHeight) / 2),
                                     YSFEmoticon_kDeleteWidth,
                                     YSFEmoticon_kDeleteHeight);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.itemData.type == YSFEmoticonTypeDelete) {
        _deleteButton.highlighted = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.itemData.type == YSFEmoticonTypeDelete) {
        _deleteButton.highlighted = NO;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.itemData.type == YSFEmoticonTypeDelete) {
        _deleteButton.highlighted = NO;
    }
}

@end

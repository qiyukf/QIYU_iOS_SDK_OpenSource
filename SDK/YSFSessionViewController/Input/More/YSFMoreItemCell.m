//
//  YSFMoreItemCell.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/2/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMoreItemCell.h"
#import "YSFMoreDefines.h"
#import "QYCustomUIConfig+Private.h"
#import "YSFIconButton.h"

@interface YSFMoreItemCell ()

@property (nonatomic, strong) YSFIconButton *button;

@end


@implementation YSFMoreItemCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _button = [[YSFIconButton alloc] initWithFrame:CGRectZero];
        _button.userInteractionEnabled = NO;
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)setItemData:(QYCustomInputItem *)itemData {
    _itemData = itemData;
    _button.title = itemData.text;
    _button.normalImage = itemData.normalImage;
    _button.highlightedImage = itemData.selectedImage;
    _button.imageSize = CGSizeMake(YSFMore_kItemImageSize, YSFMore_kItemImageSize);
    _button.titleHeight = YSFMore_kItemTitleHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _button.frame = self.bounds;
}

@end

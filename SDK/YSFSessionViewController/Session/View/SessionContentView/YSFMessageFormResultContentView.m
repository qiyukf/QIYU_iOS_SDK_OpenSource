//
//  YSFMessageFormResultContentView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/3/28.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormResultContentView.h"
#import "YSFMessageModel.h"
#import "YSFMessageFormResultObject.h"

static CGFloat kMessageFormResultTopSpace = 10.0f;
static CGFloat kMessageFormResultLeftSpace = 8.0f;
static CGFloat kMessageFormResultRightSpace = 11.0f;
static CGFloat kMessageFormResultVerticalGap_1 = 5.0f;
static CGFloat kMessageFormResultVerticalGap_2 = 1.0f;
static CGFloat kMessageFormResultHorizontalGap = 5.0f;
static CGFloat kMessageFormResultNameWidth = 70.0f;
static CGFloat kMessageFormResultColonWidth = 12.0f;
static CGFloat kMessageFormResultNameHeight = 18.0f;
static CGFloat kMessageFormResultMaxHeight = 56.0f;


@interface YSFMessageFormResultContentView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation YSFMessageFormResultContentView
- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    CGFloat line = 1.0 / [UIScreen mainScreen].scale;
    CGFloat width = CGRectGetWidth(self.bounds) - kMessageFormResultLeftSpace - kMessageFormResultRightSpace;
    CGFloat height = CGRectGetHeight(self.bounds) - 2 * kMessageFormResultTopSpace;
    _contentView.frame = CGRectMake(kMessageFormResultLeftSpace, kMessageFormResultTopSpace, width, height);
    [_contentView ysf_removeAllSubviews];
    
    YSF_NIMMessage *message = self.model.message;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)message.messageObject;
    YSFMessageFormResultObject *result = (YSFMessageFormResultObject *)object.attachment;
    
    
    CGFloat offset_Y = 0;
    if (result.title.length) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = YSFColorFromRGB(0x333333);
        _titleLabel.text = result.title;
        [_contentView addSubview:_titleLabel];
        
        CGFloat textHeight = [self caculateLabelHeight:_titleLabel.text width:width font:_titleLabel.font];
        textHeight = MIN(textHeight, kMessageFormResultMaxHeight);
        _titleLabel.frame = CGRectMake(0, offset_Y, width, textHeight);
        offset_Y += CGRectGetHeight(_titleLabel.frame);
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = YSFColorFromRGB(0x498fd5);
        lineView.frame = CGRectMake(0, offset_Y + kMessageFormResultVerticalGap_1, width, line);
        [_contentView addSubview:lineView];
    }
    offset_Y += kMessageFormResultVerticalGap_1 * 2;
    for (NSDictionary *dict in result.fields) {
        NSString *name = [dict.allKeys firstObject];
        NSString *value = [dict.allValues firstObject];
        if (name.length) {
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.numberOfLines = 1;
            nameLabel.font = [UIFont systemFontOfSize:14.0f];
            nameLabel.textColor = YSFColorFromRGB(0x333333);
            nameLabel.text = name;
            CGFloat textWidth = [self caculateLabelWidth:nameLabel.text height:kMessageFormResultNameHeight font:nameLabel.font];
            textWidth = MIN(textWidth, kMessageFormResultNameWidth);
            nameLabel.frame = CGRectMake(0, offset_Y, textWidth, kMessageFormResultNameHeight);
            [_contentView addSubview:nameLabel];

            UILabel *colonLabel = [[UILabel alloc] init];
            colonLabel.numberOfLines = 1;
            colonLabel.font = [UIFont systemFontOfSize:14.0f];
            colonLabel.textColor = YSFColorFromRGB(0x333333);
            colonLabel.text = @":";
            colonLabel.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame), offset_Y, kMessageFormResultColonWidth, kMessageFormResultNameHeight);
            [_contentView addSubview:colonLabel];

            if (value.length) {
                UILabel *valueLabel = [[UILabel alloc] init];
                valueLabel.numberOfLines = 0;
                valueLabel.font = [UIFont systemFontOfSize:14.0f];
                valueLabel.textColor = YSFColorFromRGB(0x333333);
                valueLabel.text = value;
                [_contentView addSubview:valueLabel];

                CGFloat valueWidth = width - kMessageFormResultNameWidth - kMessageFormResultColonWidth - kMessageFormResultHorizontalGap;
                CGFloat textHeight = [self caculateLabelHeight:valueLabel.text width:valueWidth font:valueLabel.font];
                textHeight = MIN(textHeight, kMessageFormResultMaxHeight);
                valueLabel.frame = CGRectMake(kMessageFormResultNameWidth + kMessageFormResultColonWidth + kMessageFormResultHorizontalGap,
                                              offset_Y,
                                              valueWidth,
                                              textHeight);
                offset_Y += CGRectGetHeight(valueLabel.frame);
            } else {
                offset_Y += CGRectGetHeight(nameLabel.frame);
            }
        }
        offset_Y += kMessageFormResultVerticalGap_2;
    }
}

- (CGFloat)caculateLabelWidth:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    NSDictionary *dict = @{ NSFontAttributeName : font };
    CGFloat textWidth = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:dict
                                             context:nil].size.width;
    textWidth += 2;
    return roundf(textWidth);
}

- (CGFloat)caculateLabelHeight:(NSString *)string width:(CGFloat)width font:(UIFont *)font {
    NSDictionary *dict = @{ NSFontAttributeName : font };
    CGFloat textHeight = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:dict
                                              context:nil].size.height;
    textHeight += 2;
    return roundf(textHeight);
}

//override
//商品信息展示需要显示白色底
- (UIImage *)chatNormalBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

//override
//商品信息展示需要显示白色底
- (UIImage *)chatHighlightedBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

@end

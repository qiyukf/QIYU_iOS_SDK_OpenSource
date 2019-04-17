//
//  YSFEmoticonLoadingView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/22.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonLoadingView.h"
#import "YSFEmoticonDefines.h"
#import "YSFTools.h"


@interface YSFEmoticonLoadingView ()

@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *failImageView;
@property (nonatomic, strong) UIButton *refreshButton;

@end


@implementation YSFEmoticonLoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YSFColorFromRGB(0xf7f7f7);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetFrame];
}

- (void)setType:(YSFEmoticonLoadingType)type {
    _type = type;
    self.label.hidden = NO;
    self.indicator.hidden = YES;
    if (self.indicator.isAnimating) {
        [self.indicator stopAnimating];
    }
    self.failImageView.hidden = YES;
    self.refreshButton.hidden = YES;
    if (type == YSFEmoticonLoadingTypeLoading) {
        self.indicator.hidden = NO;
        self.label.text = @"正在加载，请稍候…";
        [self.indicator startAnimating];
    } else if (type == YSFEmoticonLoadingTypeFail) {
        self.failImageView.hidden = NO;
        self.refreshButton.hidden = NO;
        _failImageView.image = [UIImage ysf_imageInKit:@"icon_loading_fail"];
        self.label.text = @"加载失败，请稍后重试";
    } else if (type == YSFEmoticonLoadingTypeNoData) {
        self.failImageView.hidden = NO;
        _failImageView.image = [UIImage ysf_imageInKit:@"icon_tip_noData"];
        self.label.text = @"企业未上传表情数据";
    }
    [self resetFrame];
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self addSubview:_seperatorLine];
    }
    return _seperatorLine;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:14.0f];
        _label.textColor = [UIColor grayColor];
        [self addSubview:_label];
    }
    return _label;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _indicator.color = [UIColor grayColor];
        CGAffineTransform transform = CGAffineTransformMakeScale(.8f, .8f);
        _indicator.transform = transform;
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (UIImageView *)failImageView {
    if (!_failImageView) {
        _failImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _failImageView.backgroundColor = [UIColor clearColor];
        _failImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_failImageView];
    }
    return _failImageView;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.backgroundColor = [UIColor clearColor];
        _refreshButton.layer.cornerRadius = 5.0f;
        _refreshButton.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _refreshButton.layer.borderColor = [UIColor grayColor].CGColor;
        _refreshButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_refreshButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        [_refreshButton addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_refreshButton];
    }
    return _refreshButton;
}

- (void)resetFrame {
    self.seperatorLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0 / [UIScreen mainScreen].scale);
    if (self.type == YSFEmoticonLoadingTypeLoading) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFEmoticon_kLoadingIndicatorSize - YSFEmoticon_kLoadingSpace - YSFEmoticon_kLoadingLabelHeight) / 2);
        self.indicator.center = CGPointMake(ROUND_SCALE(CGRectGetWidth(self.frame) / 2), ROUND_SCALE(top + (YSFEmoticon_kLoadingIndicatorSize / 2)));
        self.label.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.indicator.frame) + YSFEmoticon_kLoadingSpace,
                                      CGRectGetWidth(self.frame),
                                      YSFEmoticon_kLoadingLabelHeight);
    } else if (self.type == YSFEmoticonLoadingTypeFail) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFEmoticon_kLoadingFailImageHeight - YSFEmoticon_kLoadingLabelHeight - YSFEmoticon_kLoadingButtonHeight - 2 * YSFEmoticon_kLoadingFailSpace) / 2);
        self.failImageView.frame = CGRectMake(0, top, CGRectGetWidth(self.frame), YSFEmoticon_kLoadingFailImageHeight);
        self.label.frame = CGRectMake(0, CGRectGetMaxY(self.failImageView.frame) + YSFEmoticon_kLoadingFailSpace, CGRectGetWidth(self.frame), YSFEmoticon_kLoadingLabelHeight);
        self.refreshButton.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.frame) - YSFEmoticon_kLoadingButtonWidth) / 2),
                                              CGRectGetMaxY(self.label.frame) + YSFEmoticon_kLoadingFailSpace,
                                              YSFEmoticon_kLoadingButtonWidth,
                                              YSFEmoticon_kLoadingButtonHeight);
    } else if (self.type == YSFEmoticonLoadingTypeNoData) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFEmoticon_kLoadingNoDataImageHeight - YSFEmoticon_kLoadingFailSpace - YSFEmoticon_kLoadingLabelHeight) / 2);
        self.failImageView.frame = CGRectMake(0, top, CGRectGetWidth(self.frame), YSFEmoticon_kLoadingNoDataImageHeight);
        self.label.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.failImageView.frame) + YSFEmoticon_kLoadingFailSpace,
                                      CGRectGetWidth(self.frame),
                                      YSFEmoticon_kLoadingLabelHeight);
    }
}

- (void)onTouchButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapRefreshButton:)]) {
        [self.delegate tapRefreshButton:sender];
    }
}

@end

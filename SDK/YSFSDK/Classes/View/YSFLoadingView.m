//
//  YSFLoadingView.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFLoadingView.h"
#import "YSFTools.h"

static CGFloat YSFLoadingIndicatorSize = 50.0f;
static CGFloat YSFLoadingSpace = 20.0f;
static CGFloat YSFLoadingLabelHeight = 30.0f;
static CGFloat YSFLoadingFailImageHeight = 50.0f;
static CGFloat YSFLoadingFailSpace = 15.0f;
static CGFloat YSFLoadingButtonWidth = 50.0f;
static CGFloat YSFLoadingButtonHeight = 28.0f;
static CGFloat YSFLoadingNoDataImageHeight = 80.0f;


@interface YSFLoadingView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *failImageView;
@property (nonatomic, strong) UIButton *refreshButton;

@end


@implementation YSFLoadingView
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

- (void)setType:(YSFLoadingType)type {
    _type = type;
    self.label.hidden = NO;
    self.indicator.hidden = YES;
    if (self.indicator.isAnimating) {
        [self.indicator stopAnimating];
    }
    self.failImageView.hidden = YES;
    self.refreshButton.hidden = YES;
    if (type == YSFLoadingTypeLoading) {
        self.indicator.hidden = NO;
        self.label.text = @"正在加载，请稍候…";
        [self.indicator startAnimating];
    } else if (type == YSFLoadingTypeFail) {
        self.failImageView.hidden = NO;
        self.refreshButton.hidden = NO;
        _failImageView.image = [UIImage ysf_imageInKit:@"icon_loading_fail"];
        self.label.text = @"加载失败，请稍后重试";
    } else if (type == YSFLoadingTypeNoData) {
        self.failImageView.hidden = NO;
        _failImageView.image = [UIImage ysf_imageInKit:@"icon_tip_noData"];
        self.label.text = @"暂无数据";
    }
    [self resetFrame];
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
    if (self.type == YSFLoadingTypeLoading) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFLoadingIndicatorSize - YSFLoadingSpace - YSFLoadingLabelHeight) / 2);
        self.indicator.center = CGPointMake(ROUND_SCALE(CGRectGetWidth(self.frame) / 2), ROUND_SCALE(top + (YSFLoadingIndicatorSize / 2)));
        self.label.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.indicator.frame) + YSFLoadingSpace,
                                      CGRectGetWidth(self.frame),
                                      YSFLoadingLabelHeight);
    } else if (self.type == YSFLoadingTypeFail) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFLoadingFailImageHeight - YSFLoadingLabelHeight - YSFLoadingButtonHeight - 2 * YSFLoadingFailSpace) / 2);
        self.failImageView.frame = CGRectMake(0, top, CGRectGetWidth(self.frame), YSFLoadingFailImageHeight);
        self.label.frame = CGRectMake(0, CGRectGetMaxY(self.failImageView.frame) + YSFLoadingFailSpace, CGRectGetWidth(self.frame), YSFLoadingLabelHeight);
        self.refreshButton.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.frame) - YSFLoadingButtonWidth) / 2),
                                              CGRectGetMaxY(self.label.frame) + YSFLoadingFailSpace,
                                              YSFLoadingButtonWidth,
                                              YSFLoadingButtonHeight);
    } else if (self.type == YSFLoadingTypeNoData) {
        CGFloat top = ROUND_SCALE((CGRectGetHeight(self.frame) - YSFLoadingNoDataImageHeight - YSFLoadingFailSpace - YSFLoadingLabelHeight) / 2);
        self.failImageView.frame = CGRectMake(0, top, CGRectGetWidth(self.frame), YSFLoadingNoDataImageHeight);
        self.label.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.failImageView.frame) + YSFLoadingFailSpace,
                                      CGRectGetWidth(self.frame),
                                      YSFLoadingLabelHeight);
    }
}

- (void)onTouchButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapRefreshButton:)]) {
        [self.delegate tapRefreshButton:sender];
    }
}


@end

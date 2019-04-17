//
//  YSFSessionTipView.m
//  YSFSDK
//
//  Created by amao on 9/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFSessionTipView.h"
#import "YSFAttributedLabel.h"
#import "QYCustomUIConfig.h"
#import "YSFTipDetailViewController.h"
#import "YSFTools.h"


@interface YSFSessionTipView () <YSFAttributedLabelDelegate>

@property (nonatomic, assign) YSFSessionTipType type;
@property (nonatomic, strong) YSFAttributedLabel *tipLabel;
@property (nonatomic, strong) UIButton *rightArraw;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, assign) BOOL showNumber;

@end


@implementation YSFSessionTipView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[QYCustomUIConfig sharedInstance] sessionTipBackgroundColor];
        
        _tipLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        [_tipLabel setFont:[UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] sessionTipTextFontSize]]];
        [_tipLabel setTextColor:[[QYCustomUIConfig sharedInstance] sessionTipTextColor]];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setText:@"网络连接失败，请稍后再试"];
        _tipLabel.linkColor = YSFRGBA2(0xff12b8fb);
        _tipLabel.autoDetectLinks = NO;
        _tipLabel.autoDetectNumber = NO;
        _tipLabel.numberOfLines = 1;
        _tipLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
        _tipLabel.textAlignment = kCTTextAlignmentCenter;
        _tipLabel.delegate = self;
        [self addSubview:_tipLabel];

        _rightArraw = [[UIButton alloc] initWithFrame:CGRectZero];
        [_rightArraw setImage:[UIImage ysf_imageInKit:@"icon_right_arrow"] forState:UIControlStateNormal];
        [self addSubview:_rightArraw];
        _rightArraw.hidden = YES;
        
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        [self addSubview:_seperatorLine];
        
        _showNumber = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tipLabel.frame = CGRectMake(10, 9, self.ysf_frameWidth - 40, [self getTipLabelHeight]);
    CGSize imageSize = [_rightArraw imageForState:UIControlStateNormal].size;
    _rightArraw.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _rightArraw.ysf_frameLeft = ROUND_SCALE((30 - imageSize.width) / 2 + CGRectGetMaxX(_tipLabel.frame));
    _rightArraw.ysf_frameCenterY = self.ysf_frameHeight / 2;
    
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    _seperatorLine.frame = CGRectMake(0, CGRectGetHeight(self.frame) - lineHeight, CGRectGetWidth(self.frame), lineHeight);
}

- (CGFloat)getTipLabelHeight {
    CGFloat height = [_tipLabel sizeThatFits:CGSizeMake(_tipLabel.ysf_frameWidth, CGFLOAT_MAX)].height;
    if (height > 44) {
        height = 44;
    }
    return height;
}

- (void)setSessionTip:(YSFSessionTipType)type {
    if (![self shouldTip:type]) {
        return;
    }
    _rightArraw.hidden = YES;
    [self removeTarget:self action:@selector(onSingleTap:) forControlEvents:UIControlEventTouchUpInside];
    _type = type;
    switch (_type) {
        case YSFSessionTipOK:
        case YSFSessionTipNetworkOK: {
            self.hidden = YES;
        }
            break;
        case YSFSessionTipNetworkError: {
            [_tipLabel setText:@"网络连接失败，请稍后再试"];
            self.hidden = NO;
        }
            break;
        case YSFSessionTipRequestServiceFailed: {
            NSString *text = @"连接失败，您可以尝试重新连接";
            [_tipLabel setText:text];
            NSRange range = NSMakeRange([text length] - 4, 4);
            [_tipLabel addCustomLink:@"reconnect" forRange:range];
            self.hidden = NO;
        }
            break;
        case YSFSessionTipServiceNotExsit: {
            _rightArraw.hidden = NO;
            [self addTarget:self action:@selector(onSingleTap:) forControlEvents:UIControlEventTouchUpInside];
            [_tipLabel setText:@"当前客服不在线，如需帮助请留言"];
            self.hidden = NO;
        }
            break;
        default:
            break;
    }
    [[self ysf_viewController].view setNeedsLayout];
}

- (void)setSessionTipForWaiting:(BOOL)showNumber
                  waitingNumber:(NSInteger)waitingNumber
                     inQueeuStr:(NSString *)inQueeuStr {
    self.showNumber = showNumber;
    if (![self shouldTip:YSFSessionTipServicewaiting]) {
        return;
    }
    _type = YSFSessionTipServicewaiting;
    
    NSString * tip_str = [NSString stringWithFormat:@"排队中，您排在第%ld位，排到将自动接入。", (long)waitingNumber];
    if (!_showNumber) {
        tip_str = inQueeuStr;
    }
    tip_str = [tip_str stringByAppendingString:@"退出排队"];
    [_tipLabel setText:tip_str];
    NSRange range = NSMakeRange([tip_str length] - 4, 4);
    [_tipLabel addCustomLink:@"quitWaiting" forRange:range];
    self.hidden = NO;
    [[self ysf_viewController].view setNeedsLayout];
}

- (void)setSessionTipForNotExist:(NSString *)tip {
    [self setSessionTip:YSFSessionTipServiceNotExsit];
    if (tip.length != 0) {
        [_tipLabel setText:tip];
    }
}

- (BOOL)shouldTip:(YSFSessionTipType)type {
    //当前如果不是网络错误,则忽略传入的网络状态好转的状态
    if (type == YSFSessionTipNetworkOK && _type != YSFSessionTipNetworkError) {
        return false;
    }
    //当前是网络错误,则忽略其他所有的错误
    if (_type == YSFSessionTipNetworkError
        && type != YSFSessionTipNetworkOK
        && type != YSFSessionTipOK) {
        return false;
    }
    return true;
}

#pragma mark - Action
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label clickedOnLink:(id)linkData {
    NSString *idString = linkData;
    if (_delegate && [_delegate respondsToSelector:@selector(tipViewRequestService:)]) {
        if ([idString isEqualToString:@"reconnect"]) {
            [_delegate tipViewRequestService:self];
        } else if ([idString isEqualToString:@"quitWaiting"]) {
            [_delegate quitWaiting:self];
        }
    }
}

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    YSFTipDetailViewController *detailVC = [[YSFTipDetailViewController alloc] initWithDetailText:_tipLabel.attributedString.string];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 0);
    [closeButton setImage:[UIImage ysf_imageInKit:@"icon_close_normal"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage ysf_imageInKit:@"icon_close_highlighted"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    detailVC.navigationItem.rightBarButtonItem = item;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detailVC];
    [self.ysf_viewController presentViewController:nav animated:YES completion:nil];
}

- (void)onBack:(id)sender {
    [self.ysf_viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

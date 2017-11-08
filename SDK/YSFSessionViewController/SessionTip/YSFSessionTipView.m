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

@interface YSFSessionTipView ()<YSFAttributedLabelDelegate>
@property (nonatomic,strong)    YSFAttributedLabel *tipLabel;
@property (nonatomic,strong)    UIButton *rightArraw;
@property (nonatomic,assign)    YSFSessionTipType type;
@property (nonatomic,assign)    BOOL showNumber;
@end

@implementation YSFSessionTipView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[QYCustomUIConfig sharedInstance] sessionTipBackgroundColor];
        _tipLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        CGFloat textFontSize = [[QYCustomUIConfig sharedInstance] sessionTipTextFontSize];
        [_tipLabel setFont:[UIFont systemFontOfSize:textFontSize]];
        [_tipLabel setTextColor:[[QYCustomUIConfig sharedInstance] sessionTipTextColor]];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setText:@"网络连接失败，请稍后再试"];
        _tipLabel.autoDetectLinks = NO;
        _tipLabel.autoDetectNumber = NO;
        _tipLabel.numberOfLines = 2;
        _tipLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
        _tipLabel.textAlignment = kCTTextAlignmentCenter;
        _tipLabel.delegate = self;
        [self addSubview:_tipLabel];

        _rightArraw = [[UIButton alloc] initWithFrame:CGRectZero];
        [_rightArraw setImage:[UIImage ysf_imageInKit:@"icon_right_arrow"] forState:UIControlStateNormal];
        [self addSubview:_rightArraw];
        
        _showNumber = YES;
        
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        singleTapRecognizer.numberOfTouchesRequired = 1;
        singleTapRecognizer.cancelsTouchesInView = NO;
        singleTapRecognizer.delaysTouchesEnded = NO;
        [self addGestureRecognizer:singleTapRecognizer];
    }
    return self;
}

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    YSFTipDetailViewController *vc = [[YSFTipDetailViewController alloc] initWithDetailText:_tipLabel.attributedString.string];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.ysf_viewController presentViewController:nav animated:YES completion:nil];
    
    vc.navigationItem.title = @"详情";
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
}

- (void)onBack:(id)sender
{
    [self.ysf_viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setSessionTip:(YSFSessionTipType)type
{
    BOOL should_tip = [self shouldTip:type];
    if (!should_tip) {
        return;
    }
    
    _type = type;
    switch (_type) {
        case YSFSessionTipOK:
        case YSFSessionTipNetworkOK:
        {
            [self setHidden:YES];
        }
            break;
        case YSFSessionTipNetworkError:
        {
            [_tipLabel setText:@"网络连接失败，请稍后再试"];
            [self setHidden:NO];
        }
            break;
        case YSFSessionTipRequestServiceFailed:
        {
            NSString *text = @"连接客服失败，您可以尝试重新连接";
            [_tipLabel setText:text];
            NSRange range = NSMakeRange([text length] - 4, 4);
            
            [_tipLabel addCustomLink:[NSNull null]
                            forRange:range];
            
            [self setHidden:NO];
        }
            break;
            
        case YSFSessionTipServiceNotExsit:
        {
            [_tipLabel setText:@"当前客服不在线，如需帮助请留言"];
            [self setHidden:NO];
        }
            break;
        default:
            break;
    }
    
    [[self ysf_viewController].view setNeedsLayout];
}

- (void)setSessionTipForWaiting:(BOOL)showNumber waitingNumber:(NSInteger)waitingNumber
                    inQueeuStr:(NSString *)inQueeuStr
{
    self.showNumber = showNumber;
    BOOL should_tip = [self shouldTip:YSFSessionTipServicewaiting];
    if (!should_tip) {
        return;
    }
    
    _type = YSFSessionTipServicewaiting;
    NSString * tip_str = [NSString stringWithFormat:@"正在排队，您的前面还有%ld个人，请稍等...", (long)waitingNumber];
    if (!_showNumber) {
        tip_str = inQueeuStr;
    }
    [_tipLabel setText:tip_str];
    [self setHidden:NO];
    [[self ysf_viewController].view setNeedsLayout];
}

- (void)setSessionTipForNotExist:(NSString *)tip
{
    [self setSessionTip:YSFSessionTipServiceNotExsit];
    if (tip.length != 0) {
        [_tipLabel setText:tip];
    }
}

- (BOOL)shouldTip:(YSFSessionTipType)type
{
    //当前如果不是网络错误,则忽略传入的网络状态好转的状态
    if (type == YSFSessionTipNetworkOK &&
        _type!= YSFSessionTipNetworkError)
    {
        return false;
    }
    
    //当前是网络错误,则忽略其他所有的错误
    if (_type == YSFSessionTipNetworkError &&
        type != YSFSessionTipNetworkOK &&
        type != YSFSessionTipOK)
    {
        return false;
    }
    
    return true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tipLabel.ysf_frameWidth = self.ysf_frameWidth - 40;
    _tipLabel.ysf_frameHeight = [self getTipLabelHeight];
    _tipLabel.ysf_frameLeft = 10;
    _tipLabel.ysf_frameCenterY = self.ysf_frameHeight / 2 + 3;

    [_rightArraw sizeToFit];
    _rightArraw.ysf_frameLeft = self.ysf_frameWidth - 20;
    _rightArraw.ysf_frameCenterY = self.ysf_frameHeight / 2 + 1;
}

- (CGFloat)getTipLabelHeight
{
    CGFloat height = [_tipLabel sizeThatFits:CGSizeMake(_tipLabel.ysf_frameWidth, CGFLOAT_MAX)].height;
    if (height > 44) {
        height = 44;
    }
    
    return height;
}

- (void)ysfAttributedLabel:(YSFAttributedLabel *)label clickedOnLink:(id)linkData
{
    if (_delegate && [_delegate respondsToSelector:@selector(tipViewRequestService:)])
    {
        [_delegate tipViewRequestService:self];
    }
}
@end

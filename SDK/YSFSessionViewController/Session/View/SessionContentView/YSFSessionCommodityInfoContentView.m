//
//  YSFSessionProductInfoContentView.m
//  YSFSessionViewController
//
//  Created by JackyYu on 16/5/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFSessionCommodityInfoContentView.h"
#import "YSFMessageModel.h"
#import "QYCommodityInfo_private.h"
#import "UIControl+BlocksKit.h"
#import "YSFApiDefines.h"

@interface YSFSessionCommodityInfoContentView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UILabel *skuLabel;
@property (nonatomic, strong) UILabel *orderStatusLabel;
@property (nonatomic, strong) UILabel *payMoney;
@property (nonatomic, strong) UILabel *orderCount;
@property (nonatomic, strong) UILabel *orderIdLabel;
@property (nonatomic, strong) UILabel *orderTimeLabel;
@property (nonatomic, strong) UIView *splitLine1;
@property (nonatomic, strong) UIView *splitLine2;
@property (nonatomic, strong) UIView *splitLine3;
@property (nonatomic, strong) UIButton *activeLabel;
@property (nonatomic, strong) UIView *buttonArray;
@property (nonatomic, strong) UIView *splitLine4;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIControl *content;

@end

@implementation YSFSessionCommodityInfoContentView

- (instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView])
    {
        _content = [UIControl new];
        [self addSubview:_content];
        [_content addTarget:self action:@selector(onClickContent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)setupCommodityInfoView
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 1;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.textColor = YSFRGB(0x222222);
    _titleLabel.font = [UIFont systemFontOfSize:14.f];
    [_titleLabel sizeToFit];
    [_content addSubview:_titleLabel];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _descLabel.backgroundColor = [UIColor clearColor];
    _descLabel.numberOfLines = 2;
    _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _descLabel.textColor = YSFRGB(0x666666);
    _descLabel.font = [UIFont systemFontOfSize:12.f];
    [_descLabel sizeToFit];
    [_content addSubview:_descLabel];
    
    _payMoney = [[UILabel alloc] initWithFrame:CGRectZero];
    _payMoney.backgroundColor = [UIColor clearColor];
    _payMoney.lineBreakMode = NSLineBreakByTruncatingTail;
    _payMoney.textColor = YSFRGB(0x222222);
    _payMoney.font = [UIFont systemFontOfSize:12.f];
    [_payMoney sizeToFit];
    [_content addSubview:_payMoney];
    
    _orderCount = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderCount.backgroundColor = [UIColor clearColor];
    _orderCount.lineBreakMode = NSLineBreakByTruncatingTail;
    _orderCount.textColor = YSFRGB(0x222222);
    _orderCount.font = [UIFont systemFontOfSize:12.f];
    [_orderCount sizeToFit];
    [_content addSubview:_orderCount];
    
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _noteLabel.backgroundColor = [UIColor clearColor];
    _noteLabel.numberOfLines = 1;
    _noteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _noteLabel.textColor = YSFRGB(0xff611b);
    _noteLabel.font = [UIFont systemFontOfSize:12.f];
    [_noteLabel sizeToFit];
    [_content addSubview:_noteLabel];
    
    _skuLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _skuLabel.backgroundColor = [UIColor clearColor];
    _skuLabel.numberOfLines = 1;
    _skuLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _skuLabel.textColor = YSFRGB(0x222222);
    _skuLabel.font = [UIFont systemFontOfSize:12.f];
    [_skuLabel sizeToFit];
    [_content addSubview:_skuLabel];
    
    _orderStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderStatusLabel.backgroundColor = [UIColor clearColor];
    _orderStatusLabel.numberOfLines = 1;
    _orderStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _orderStatusLabel.textColor = YSFRGB(0xff611b);
    _orderStatusLabel.font = [UIFont systemFontOfSize:12.f];
    [_orderStatusLabel sizeToFit];
    [_content addSubview:_orderStatusLabel];
    
    _splitLine1 = [UIView new];
    _splitLine1.backgroundColor = YSFRGB(0xdbdbdb);
    [_content addSubview:_splitLine1];
    
    _orderIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderIdLabel.backgroundColor = [UIColor clearColor];
    _orderIdLabel.numberOfLines = 1;
    _orderIdLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _orderIdLabel.textColor = YSFRGB(0x666666);
    _orderIdLabel.font = [UIFont systemFontOfSize:14.f];
    [_content addSubview:_orderIdLabel];
    
    _orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderTimeLabel.backgroundColor = [UIColor clearColor];
    _orderTimeLabel.numberOfLines = 1;
    _orderTimeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _orderTimeLabel.textColor = YSFRGB(0x666666);
    _orderTimeLabel.font = [UIFont systemFontOfSize:14.f];
    [_content addSubview:_orderTimeLabel];
    
    _splitLine2 = [UIView new];
    _splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
    [_content addSubview:_splitLine2];
    
    _activeLabel = [[UIButton alloc] initWithFrame:CGRectZero];
    _activeLabel.backgroundColor = [UIColor clearColor];
    [_activeLabel setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    _activeLabel.titleLabel.font = [UIFont systemFontOfSize:14.f];
    _activeLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _activeLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_content addSubview:_activeLabel];
    
    _defaultImage = [UIImage ysf_imageInKit:@"icon_commodityInfo_default_picture"];
    _productImageView = [[UIImageView alloc] initWithImage:_defaultImage];
    _productImageView.backgroundColor = [UIColor clearColor];
    _productImageView.contentMode = UIViewContentModeScaleAspectFill;
    _productImageView.clipsToBounds = YES;
    [_content addSubview:_productImageView];
    
    _splitLine3 = [UIView new];
    _splitLine3.backgroundColor = YSFRGB(0xdbdbdb);
    [_content addSubview:_splitLine3];
    _buttonArray = [UIView new];
    [_content addSubview:_buttonArray];
    
    _splitLine4 = [UIView new];
    _splitLine4.backgroundColor = YSFRGB(0xdbdbdb);
    [_content addSubview:_splitLine4];
    _actionButton = [UIButton new];
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    _actionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_actionButton setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    [_actionButton addTarget:self action:@selector(onClickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    [_content addSubview:_actionButton];
}

- (void)refresh:(YSFMessageModel *)data
{
    [super refresh:data];
    
    [_content ysf_removeAllSubviews];
    [self setupCommodityInfoView];
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    QYCommodityInfo *attachment = (QYCommodityInfo *)object.attachment;
    
    [_productImageView setImage:_defaultImage];
    if (attachment.pictureUrlString) {
        NSString *pictureUrlString = [attachment.pictureUrlString ysf_trim];
        pictureUrlString = [pictureUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *imageUrl = [NSURL URLWithString:pictureUrlString];
        [self setUserAgent];
        [[YSFWebImageManager sharedManager] loadImageWithURL:imageUrl options:YSFWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, YSFImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!error && finished) {
                self.productImageView.image = image;
                [self setNeedsLayout];
            }
        }];
    }
    
    if (!attachment.isCustom) {
        [_titleLabel setText:attachment.title];
        [_descLabel setText:attachment.desc];
        [_payMoney setText:attachment.payMoney];
        [_orderCount setText:attachment.orderCount];
        
        [_noteLabel setText:attachment.note];
        [_skuLabel setText:attachment.orderSku];
        [_orderStatusLabel setText:attachment.orderStatus];
        if (attachment.orderId.length > 0) {
            [_orderIdLabel setText:[NSString stringWithFormat:@"订单编号：%@", attachment.orderId]];
            _orderIdLabel.hidden = NO;
        }
        else {
            _orderIdLabel.hidden = YES;
        }
        if (attachment.orderTime.length > 0) {
            [_orderTimeLabel setText:[NSString stringWithFormat:@"下单时间：%@", attachment.orderTime]];
            _orderTimeLabel.hidden = NO;
        }
        else {
            _orderTimeLabel.hidden = YES;
        }
        if (attachment.orderId.length > 0 || attachment.orderTime.length > 0) {
            _splitLine1.hidden = NO;
        }
        else {
            _splitLine1.hidden = YES;
        }
        if (attachment.activity.length > 0) {
            _splitLine2.hidden = NO;
        }
        else {
            _splitLine2.hidden = YES;
        }
        [_activeLabel setTitle:attachment.activity forState:UIControlStateNormal];
        _activeLabel.hidden = attachment.activity.length == 0;
        __weak typeof(self) weakSelf = self;
        [_activeLabel ysf_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
        [_activeLabel ysf_addEventHandler:^(id  _Nonnull sender) {
            YSFKitEvent *event = [[YSFKitEvent alloc] init];
            event.eventName = YSFKitEventNameTapLabelLink;
            event.message = weakSelf.model.message;
            event.data = attachment.activityHref;
            [weakSelf.delegate onCatchEvent:event];
        } forControlEvents:UIControlEventTouchUpInside];
        
        if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
            _splitLine3.hidden = attachment.tagsArray.count == 0;
            __block UIButton *button;
            __block CGFloat right = 5;
            __block CGFloat top = 0;
            _buttonArray.hidden = attachment.tagsArray.count == 0;
            [_buttonArray ysf_removeAllSubviews];
            [attachment.tagsArray enumerateObjectsUsingBlock:^(QYCommodityTag *tag, NSUInteger idx, BOOL * _Nonnull stop) {
                button = [[UIButton alloc] init];
                button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
                __weak typeof(self) weakSelf = self;
                [button ysf_addEventHandler:^(id  _Nonnull sender) {
                    YSFKitEvent *event = [[YSFKitEvent alloc] init];
                    event.eventName = YSFKitEventNameTapLabelLink;
                    event.message = self.model.message;
                    event.data = tag.url;
                    [weakSelf.delegate onCatchEvent:event];
                } forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.font = [UIFont systemFontOfSize:12];
                button.layer.borderColor = YSFRGB(0x4f82ae).CGColor;
                button.layer.cornerRadius = 10;
                button.layer.borderWidth = 0.5;
                [button setTitleColor:YSFRGB(0x4f82ae) forState:UIControlStateNormal];
                [button setTitle:tag.label forState:UIControlStateNormal];
                [button sizeToFit];
                button.ysf_frameWidth += 20;
                button.ysf_frameLeft = right + 10;
                if (button.ysf_frameRight > self.ysf_frameWidth - 10) {
                    top += 22 + 10;
                    right = 5;
                    button.ysf_frameLeft = right + 10;
                }
                button.ysf_frameTop = top;
                button.ysf_frameHeight = 22;
                button.tag = idx;
                [weakSelf.buttonArray addSubview:button];
                
                right = button.ysf_frameRight;
            }];
        }
        
    }

    if (attachment.sendByUser) {
        _splitLine4.hidden = NO;
        _actionButton.hidden = NO;
        [_actionButton setTitle:attachment.actionText forState:UIControlStateNormal];
        [_actionButton setTitleColor:attachment.actionTextColor forState:UIControlStateNormal];
    } else {
        _splitLine4.hidden = YES;
        _actionButton.hidden = YES;
    }
}

//有些服务器需要userAgent验证
- (void)setUserAgent
{
    NSString *userAgent = @"";
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
    
    [[YSFWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentsize = self.model.contentSize;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    QYCommodityInfo *attachment = (QYCommodityInfo *)object.attachment;
    CGFloat offsetY = 102;

    if (attachment.isCustom) {
        offsetY = 150;
        _productImageView.ysf_frameTop = 5;
        _productImageView.ysf_frameWidth = contentsize.width + contentInsets.left + contentInsets.right - 14;
        _productImageView.ysf_frameHeight = 140;
        if (([YSF_NIMSDK sharedSDK].sdkOrKf && self.model.message.isOutgoingMsg)
            || (![YSF_NIMSDK sharedSDK].sdkOrKf && self.model.message.isOutgoingMsg)) {
            _productImageView.ysf_frameLeft = 5;
        }
        else {
            _productImageView.ysf_frameLeft = 9;
        }
    }
    else
    {
        _productImageView.ysf_frameLeft = contentInsets.left;
        _productImageView.ysf_frameTop = 14;
        _productImageView.ysf_frameWidth = 75;
        _productImageView.ysf_frameHeight = 75;
        
        _titleLabel.ysf_frameLeft = _productImageView.ysf_frameRight + 10;
        _titleLabel.ysf_frameTop = 9;;
        _titleLabel.ysf_frameWidth = contentsize.width - _productImageView.ysf_frameWidth - 10;
        _titleLabel.ysf_frameHeight = 20;
        
        _descLabel.ysf_frameLeft = _productImageView.ysf_frameRight + 10;
        _descLabel.ysf_frameTop = _titleLabel.ysf_frameBottom + 3;
        _descLabel.ysf_frameWidth = contentsize.width - _productImageView.ysf_frameWidth - 10;
        _descLabel.ysf_frameHeight = 35;
        
        [_payMoney sizeToFit];
        if (_payMoney.ysf_frameWidth > 70) {
            _payMoney.ysf_frameWidth = 70;
        }
        _payMoney.ysf_frameRight = self.ysf_frameWidth - 10;
        _payMoney.ysf_frameTop = _titleLabel.ysf_frameBottom + 8;
        
        [_orderCount sizeToFit];
        if (_orderCount.ysf_frameWidth > 70) {
            _orderCount.ysf_frameWidth = 70;
        }
        _orderCount.ysf_frameRight = self.ysf_frameWidth - 10;
        _orderCount.ysf_frameTop = _payMoney.ysf_frameBottom + 5;
        
        CGFloat rightWidth = MAX(_payMoney.ysf_frameWidth, _orderCount.ysf_frameWidth);
        _descLabel.ysf_frameWidth = _descLabel.ysf_frameWidth - rightWidth - 5;
        
        _noteLabel.ysf_frameLeft = _productImageView.ysf_frameRight + 10;
        _noteLabel.ysf_frameTop = _descLabel.ysf_frameBottom + 3;
        _noteLabel.ysf_frameWidth = contentsize.width - _productImageView.ysf_frameWidth - 10;
        _noteLabel.ysf_frameHeight = 20;
        
        [_skuLabel sizeToFit];
        _skuLabel.ysf_frameLeft = _productImageView.ysf_frameRight + 10;
        _skuLabel.ysf_frameTop = 77;
        
        [_orderStatusLabel sizeToFit];
        if (_orderStatusLabel.ysf_frameWidth > 70) {
            _orderStatusLabel.ysf_frameWidth = 70;
        }
        _orderStatusLabel.ysf_frameRight = self.ysf_frameWidth - 10;
        _orderStatusLabel.ysf_frameTop = 77;
        _skuLabel.ysf_frameWidth = contentsize.width - _productImageView.ysf_frameWidth - 10 - _orderStatusLabel.ysf_frameWidth - 5;
        
        if (!_orderIdLabel.hidden) {
            _splitLine1.ysf_frameWidth = self.ysf_frameWidth - 5;
            _splitLine1.ysf_frameLeft = 5;
            _splitLine1.ysf_frameTop = offsetY;
            _splitLine1.ysf_frameHeight = 0.5;
            
            _orderIdLabel.ysf_frameWidth = self.ysf_frameWidth - 20;
            _orderIdLabel.ysf_frameLeft = contentInsets.left;
            _orderIdLabel.ysf_frameTop = offsetY + 5;
            _orderIdLabel.ysf_frameHeight = 25;
            
            offsetY = _orderIdLabel.ysf_frameBottom;
        }
        
        _orderTimeLabel.ysf_frameWidth = self.ysf_frameWidth - 20;
        _orderTimeLabel.ysf_frameLeft = contentInsets.left;
        _orderTimeLabel.ysf_frameTop = offsetY;
        _orderTimeLabel.ysf_frameHeight = 25;
        if (!_orderTimeLabel.hidden) {
            offsetY = _orderTimeLabel.ysf_frameBottom;
        }
        
        if (!_activeLabel.hidden) {
            offsetY += 5;
            _splitLine2.ysf_frameWidth = self.ysf_frameWidth - 5;
            _splitLine2.ysf_frameLeft = 5;
            _splitLine2.ysf_frameTop = offsetY;
            _splitLine2.ysf_frameHeight = 0.5;
            
            _activeLabel.ysf_frameWidth = self.ysf_frameWidth - 20;
            _activeLabel.ysf_frameLeft = contentInsets.left;
            _activeLabel.ysf_frameTop = offsetY + 6;
            _activeLabel.ysf_frameHeight = 25;
            
            offsetY = _activeLabel.ysf_frameBottom;
            offsetY += 6;
        }
        
        if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
            if (_buttonArray.subviews.count > 0) {
                _splitLine3.ysf_frameWidth = self.ysf_frameWidth - 5;
                _splitLine3.ysf_frameLeft = 5;
                _splitLine3.ysf_frameTop = offsetY;
                _splitLine3.ysf_frameHeight = 0.5;
                
                _buttonArray.ysf_frameWidth = self.ysf_frameWidth;
                _buttonArray.ysf_frameLeft = 0;
                _buttonArray.ysf_frameTop = offsetY + 6.5;
                _buttonArray.ysf_frameHeight = 25;
                offsetY += 36;
            }
        }
    }
    
    if (attachment.sendByUser) {
        _splitLine4.ysf_frameWidth = self.ysf_frameWidth - 5;
        _splitLine4.ysf_frameLeft = 0;
        _splitLine4.ysf_frameTop = offsetY;
        _splitLine4.ysf_frameHeight = 0.5;
        
        _actionButton.ysf_frameWidth = self.ysf_frameWidth - 20;
        _actionButton.ysf_frameLeft = contentInsets.left;
        _actionButton.ysf_frameTop = offsetY;
        _actionButton.ysf_frameHeight = 36;
    }
}

- (void)onClickContent:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapCommodityInfo;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
}

- (void)onClickActionButton:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameSendCommdityInfo;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
}

#pragma mark - Private 
//override
//商品信息展示需要显示白色底
- (UIImage *)chatNormalBubbleImage
{
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

//override
//商品信息展示需要显示白色底
- (UIImage *)chatHighlightedBubbleImage
{
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

@end

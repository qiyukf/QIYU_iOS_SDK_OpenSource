#import "YSFSelectedGoodsContentView.h"
#import "NSDictionary+YSFJson.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFMessageModel.h"
#import "YSFSelectedGoods.h"

@interface YSFSelectedGoodsContentView()

@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * goodName;
@property (nonatomic,strong) UILabel * stock;
@property (nonatomic,strong) UILabel * price;
@property (nonatomic,strong) UILabel * number;
@property (nonatomic,strong) UILabel * status;
@property (nonatomic,strong) UIView *splitLine;
@property (nonatomic,strong) UIButton * button;

@end

@implementation YSFSelectedGoodsContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
        
        _goodName = [UILabel new];
        _goodName.font = [UIFont systemFontOfSize:14.f];
        _goodName.numberOfLines = 0;
        [self addSubview:_goodName];
        
        _stock = [UILabel new];
        _stock.font = [UIFont systemFontOfSize:14.f];
        _stock.textColor = YSFRGBA2(0xffa3afb7);
        _stock.numberOfLines = 0;
        [self addSubview:_stock];
        
        _price = [UILabel new];
        _price.font = [UIFont boldSystemFontOfSize:14.f];
        [self addSubview:_price];
        
        _number = [UILabel new];
        _number.font = [UIFont systemFontOfSize:14.f];
        _number.textColor = YSFRGBA2(0xffa3afb7);
        [self addSubview:_number];
        
        _status = [UILabel new];
        _status.font = [UIFont systemFontOfSize:14.f];
        _status.textColor = YSFRGBA2(0xffa3afb7);
        [self addSubview:_status];
        
        _splitLine = [UIView new];
        _splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        [self addSubview:_splitLine];
        
        _button = [UIButton new];
        _button.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_button setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];

    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFSelectedCommodityInfo *selectedGoods = (YSFSelectedCommodityInfo *)object.attachment;
    [_imageView ysf_setImageWithURL:[NSURL URLWithString:selectedGoods.goods.p_img]];
    
    _goodName.text = selectedGoods.goods.p_name;
    _stock.text = selectedGoods.goods.p_stock;
    _price.text = selectedGoods.goods.p_price;
    _number.text = selectedGoods.goods.p_count;
    _status.text = selectedGoods.goods.p_status;
    
    if ([YSF_NIMSDK sharedSDK].sdkOrKf && selectedGoods.goods.p_action.length > 0) {
        _splitLine.hidden = NO;
        _button.hidden = NO;
        [_button setTitle:selectedGoods.goods.p_action forState:UIControlStateNormal];
    } else {
        _splitLine.hidden = YES;
        _button.hidden = YES;
    }
}

- (void)layoutSubviews
{
    _imageView.ysf_frameTop = 10;
    _imageView.ysf_frameLeft = 10;
    _imageView.ysf_frameWidth = 60;
    _imageView.ysf_frameHeight = 60;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _imageView.ysf_frameLeft += 5;
    }
    
    _price.ysf_frameTop = 10;
    [_price sizeToFit];
    if (_price.ysf_frameWidth > 100) {
        _price.ysf_frameWidth = 100;
    }
    _price.ysf_frameRight = self.ysf_frameWidth - 15;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _price.ysf_frameLeft += 5;
    }
    
    _number.ysf_frameTop = 32;
    [_number sizeToFit];
    if (_number.ysf_frameWidth > 100) {
        _number.ysf_frameWidth = 100;
    }
    _number.ysf_frameRight = self.ysf_frameWidth - 15;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _number.ysf_frameLeft += 5;
    }
    
    _goodName.ysf_frameTop = 10;
    _goodName.ysf_frameLeft = 80;
    _goodName.ysf_frameWidth = self.ysf_frameWidth - 80 - 10 - 15;
    if (_price.ysf_frameWidth > _number.ysf_frameWidth) {
        _goodName.ysf_frameWidth -= _price.ysf_frameWidth;
    }
    else {
        _goodName.ysf_frameWidth -= _number.ysf_frameWidth;
    }
    if (_goodName.ysf_frameWidth < 0) {
        _goodName.ysf_frameWidth = 0;
    }
    [_goodName sizeToFit];
    if (_goodName.ysf_frameHeight > 40) {
        _goodName.ysf_frameHeight = 34;
    }
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _goodName.ysf_frameLeft += 5;
    }
    
    _status.ysf_frameTop = 52;
    [_status sizeToFit];
    if (_status.ysf_frameWidth > 100) {
        _status.ysf_frameWidth = 100;
    }
    _status.ysf_frameRight = self.ysf_frameWidth - 15;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _status.ysf_frameLeft += 5;
    }
    
    _stock.ysf_frameTop = 40;
    _stock.ysf_frameLeft = 80;
    _stock.ysf_frameHeight = 40;
    _stock.ysf_frameWidth = self.ysf_frameWidth - 80 - 10 - 15;
    _stock.ysf_frameWidth -= _status.ysf_frameWidth;
    if (_stock.ysf_frameWidth < 0) {
        _stock.ysf_frameWidth = 0;
    }
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _stock.ysf_frameLeft += 5;
    } else {
        YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
        YSFSelectedCommodityInfo *selectedGoods = (YSFSelectedCommodityInfo *)object.attachment;
        if (selectedGoods.goods.p_action.length > 0) {
            _splitLine.ysf_frameWidth = self.ysf_frameWidth - 13;
            _splitLine.ysf_frameLeft = 4;
            _splitLine.ysf_frameTop = CGRectGetMaxY(_stock.frame);
            _splitLine.ysf_frameHeight = 1. / [UIScreen mainScreen].scale;
            
            _button.ysf_frameWidth = self.ysf_frameWidth - 20;
            _button.ysf_frameLeft = 10;
            _button.ysf_frameTop = CGRectGetMaxY(_splitLine.frame);
            _button.ysf_frameHeight = 36;
        }
    }
}

- (void)onClickButton:(id)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapCommdityAction;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
}

#pragma mark - Private
//商品信息展示需要显示白色底
- (UIImage *)chatNormalBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_normal"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                    resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_normal"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                   resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

//商品信息展示需要显示白色底
- (UIImage *)chatHighlightedBubbleImage {
    UIImage *customerNormalImage = [[UIImage ysf_imageInKit:@"icon_sender_commodityInfo_pressed"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                    resizingMode:UIImageResizingModeStretch];
    UIImage *serviceNormalImage = [[UIImage ysf_imageInKit:@"icon_receiver_commodityInfo_pressed"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 10, 10)
                                   resizingMode:UIImageResizingModeStretch];
    return self.model.message.isOutgoingMsg ? customerNormalImage : serviceNormalImage;
}

@end

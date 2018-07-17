#import "YSFSelectedGoodsContentView.h"
#import "NSDictionary+YSFJson.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFMessageModel.h"
#import "YSFSelectedGoods.h"

@interface YSFSelectedGoodsContentView()

@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * goodName;
@property (nonatomic,strong) UILabel * stock;
@property (nonatomic,strong) UILabel * price;
@property (nonatomic,strong) UILabel * number;
@property (nonatomic,strong) UILabel * status;

@end

@implementation YSFSelectedGoodsContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {

        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backgroundView];
        
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
}

- (void)layoutSubviews
{
    _backgroundView.ysf_frameLeft = 2;
    _backgroundView.ysf_frameWidth = self.ysf_frameWidth - 9;
    _backgroundView.ysf_frameTop = 2;
    _backgroundView.ysf_frameHeight = self.ysf_frameHeight - 4;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _backgroundView.ysf_frameLeft += 5;
    }
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
    }
}


@end

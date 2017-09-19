#import "YSFOrderListContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "UIImageView+YSFWebCache.h"


@implementation YSFCellView
@end



@interface YSFOrderListContentView()

@property (nonatomic, strong) UIView *content;

@end

@implementation YSFOrderListContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        _content = [UIView new];
        [self addSubview:_content];
    }
    return self;
}



- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];

    [_content ysf_removeAllSubviews];
    
    __block CGFloat offsetY = self.model.contentViewInsets.top;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFOrderList *orderList = (YSFOrderList *)object.attachment;
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:16.f];
    label.text = orderList.label;
    label.frame = CGRectMake(18, offsetY + 13,
                                   self.model.contentSize.width - 28, 25);
    
    [self addSubview:label];
    
    offsetY += 44;
    
    [orderList.shops enumerateObjectsUsingBlock:^(YSFShop *shop, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            offsetY += 10;
        }
        
        UIView *shopCell = [shop createCell:self.ysf_frameWidth - 5 eventHander:self];
        shopCell.ysf_frameLeft = 5;
        shopCell.ysf_frameTop = offsetY;
        [_content addSubview:shopCell];
        
        offsetY += shopCell.ysf_frameHeight;
    }];
    
    YSFCellView *button = [YSFCellView new];
    button.itemData = orderList;
    [button setTitle:orderList.action.validOperation forState:UIControlStateNormal];
    [button setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.f];
    button.ysf_frameLeft = 5;
    button.ysf_frameWidth = self.ysf_frameWidth - 5;
    button.ysf_frameTop = offsetY;
    button.ysf_frameHeight = 40;
    [_content addSubview:button];
    [button addTarget:self action:@selector(onClickMore:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClickItem:(YSFCellView *)goodsView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapGoods;
    event.message = self.model.message;
    event.data = goodsView.itemData;
    [self.delegate onCatchEvent:event];
}

- (void)onClickMore:(YSFCellView *)actionView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapMoreOrders;
    event.message = self.model.message;
    event.data = actionView.itemData;
    [self.delegate onCatchEvent:event];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _content.ysf_frameLeft = -5;
    }
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}

@end



@implementation YSFShop(YSF)

- (UIView *)createCell:(CGFloat)width eventHander:(id)eventHander
{
    UIView *cell = [UIView new];
    cell.userInteractionEnabled = YES;
    
    __block CGFloat offsetY = 0;
    
    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 0;
    splitLine.ysf_frameWidth = width;
    splitLine.ysf_frameTop = offsetY;
    [cell addSubview:splitLine];
    
    UIImageView *shopIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    shopIcon.frame = CGRectMake(18, offsetY + 14,
                                0, 0);
    shopIcon.image = [UIImage ysf_imageInKit:@"icon_shop"];
    [shopIcon sizeToFit];
    [cell addSubview:shopIcon];
    
    UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectZero];
    shopName.font = [UIFont systemFontOfSize:13.f];
    shopName.text = self.s_name;
    shopName.textColor = YSFRGB(0x666666);
    shopName.frame = CGRectMake(18 + 24, offsetY + 14,
                                100, 16);
    [cell addSubview:shopName];
    
    UILabel *shopStatus = [[UILabel alloc] initWithFrame:CGRectZero];
    shopStatus.font = [UIFont systemFontOfSize:14.f];
    shopStatus.text = self.s_status;
    shopStatus.textColor = YSFRGB(0xff611b);
    shopStatus.frame = CGRectMake(0, offsetY + 14,
                                  0, 0);
    [shopStatus sizeToFit];
    shopStatus.ysf_frameRight = width - 10;
    [cell addSubview:shopStatus];
    
    offsetY += 40;
    
    [self.goods enumerateObjectsUsingBlock:^(YSFGoods *goods, NSUInteger idx, BOOL * _Nonnull stop) {
        YSFCellView *goodView = [YSFCellView new];
        goodView.ysf_frameTop = offsetY;
        goodView.ysf_frameHeight = 80;
        goodView.ysf_frameLeft = 0;
        goodView.ysf_frameWidth = width;
        goodView.itemData = goods;
        [cell addSubview:goodView];
        [goodView addTarget:eventHander action:@selector(onClickItem:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *splitLine2 = [UIView new];
        splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
        splitLine2.ysf_frameTop = 0;
        splitLine2.ysf_frameHeight = 0.5;
        splitLine2.ysf_frameLeft = 0;
        splitLine2.ysf_frameWidth = goodView.ysf_frameWidth;
        [goodView addSubview:splitLine2];
        
        UIImageView *imageView = [UIImageView new];
        imageView.ysf_frameTop = 10;
        imageView.ysf_frameLeft = 10;
        imageView.ysf_frameWidth = 60;
        imageView.ysf_frameHeight = 60;
        [goodView addSubview:imageView];
        NSURL *url = nil;
        if (goods.p_img) {
            url = [NSURL URLWithString:goods.p_img];
        }
        if (url) {
            [imageView ysf_setImageWithURL:url];
        }
        
        UILabel *price = [UILabel new];
        price.font = [UIFont systemFontOfSize:14.f];
        price.text = goods.p_price;
        price.ysf_frameTop = 10;
        [price sizeToFit];
        price.ysf_frameRight = goodView.ysf_frameWidth - 10;
        [goodView addSubview:price];
        
        UILabel *number = [UILabel new];
        number.font = [UIFont systemFontOfSize:14.f];
        number.numberOfLines = 0;
        number.text = goods.p_count;
        number.ysf_frameTop = 32;
        [number sizeToFit];
        number.ysf_frameRight = goodView.ysf_frameWidth - 10;
        [goodView addSubview:number];
        
        UILabel *goodName = [UILabel new];
        goodName.font = [UIFont systemFontOfSize:14.f];
        goodName.numberOfLines = 0;
        goodName.text = goods.p_name;
        goodName.ysf_frameTop = 10;
        goodName.ysf_frameLeft = 80;
        goodName.ysf_frameWidth = goodView.ysf_frameWidth - 80 - 10 - 15;
        if (price.ysf_frameWidth > number.ysf_frameWidth) {
            goodName.ysf_frameWidth -= price.ysf_frameWidth;
        }
        else {
            goodName.ysf_frameWidth -= number.ysf_frameWidth;
        }
        if (goodName.ysf_frameWidth < 0) {
            goodName.ysf_frameWidth = 0;
        }
        [goodName sizeToFit];
        if (goodName.ysf_frameHeight > 40) {
            goodName.ysf_frameHeight = 34;
        }
        [goodView addSubview:goodName];
        
        UILabel *stock = [UILabel new];
        stock.font = [UIFont systemFontOfSize:14.f];
        stock.numberOfLines = 0;
        stock.text = goods.p_stock;
        stock.ysf_frameTop = 40;
        stock.ysf_frameLeft = 80;
        stock.ysf_frameWidth = 100;
        stock.ysf_frameHeight = 40;
        [goodView addSubview:stock];
        
        UILabel *status = [UILabel new];
        status.font = [UIFont systemFontOfSize:14.f];
        status.numberOfLines = 0;
        status.text = goods.p_status;
        status.ysf_frameTop = 52;
        status.ysf_frameHeight = 40;
        [status sizeToFit];
        status.ysf_frameRight = goodView.ysf_frameWidth - 10;
        [goodView addSubview:status];
        
        offsetY += 80;
    }];
    
    UIView *splitLine3 = [UIView new];
    splitLine3.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine3.ysf_frameHeight = 0.5;
    splitLine3.ysf_frameLeft = 0;
    splitLine3.ysf_frameWidth = width;
    splitLine3.ysf_frameTop = offsetY;
    [cell addSubview:splitLine3];
    
    cell.ysf_frameWidth = width;
    cell.ysf_frameHeight = offsetY;
    return cell;
}


@end

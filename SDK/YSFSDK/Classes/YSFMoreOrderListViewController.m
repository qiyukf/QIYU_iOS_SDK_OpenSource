#import "YSFMoreOrderListViewController.h"
#import "MJRefresh.h"
#import "YSFQueryOrderListRequest.h"
#import "YSFQueryOrderListResponse.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFOrderListContentView.h"
#import "UIImageView+YSFWebCache.h"

#define cellHeight 70.0;
#define onlineSessionCellReuseIdentify @"OnlineSessionCell"
#define callCenterCellReuseIdentify @"CallCenterCell"
#define kYSFOrderCell @"YSFOrderCell"

@protocol YSFCellDelegate <NSObject>

@optional

- (void)onTapCell:(YSFGoods *)goods;

@end

@interface YSFGoodsView6 : UIButton

@property (nonatomic, strong) YSFGoods *goods;

@end

@implementation YSFGoodsView6
@end

@interface YSFActionView : UIButton

@property (nonatomic, strong) YSFOrderList *orderList;

@end

@interface YSFOrderCell : UITableViewCell

@property (nonatomic, strong) YSFShop* shop;
@property (nonatomic, weak)   id<YSFCellDelegate> delegate;

- (void)refresh:(YSFShop *)shop;

@end

@implementation YSFOrderCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    
    return self;
}

- (void)refresh:(YSFShop *)shop
{
    self.shop = shop;
    [self ysf_removeAllSubviews];
    UIView *view = [self createShopCell:YSFUIScreenWidth shop:_shop];
    view.ysf_frameWidth = self.ysf_frameWidth;
    view.ysf_frameTop = 10;
    [self addSubview:view];
}


- (UIView *)createShopCell:(CGFloat)width shop:(YSFShop *)shop
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
    shopName.text = shop.s_name;
    shopName.textColor = YSFRGB(0x666666);
    shopName.frame = CGRectMake(18 + 24, offsetY + 14,
                                100, 16);
    [cell addSubview:shopName];
    
    UILabel *shopStatus = [[UILabel alloc] initWithFrame:CGRectZero];
    shopStatus.font = [UIFont systemFontOfSize:14.f];
    shopStatus.text = shop.s_status;
    shopStatus.textColor = YSFRGB(0xff611b);
    shopStatus.frame = CGRectMake(0, offsetY + 14,
                                  0, 0);
    [shopStatus sizeToFit];
    shopStatus.ysf_frameRight = width - 10;
    [cell addSubview:shopStatus];
    
    offsetY += 40;
    
    [shop.goods enumerateObjectsUsingBlock:^(YSFGoods *goods, NSUInteger idx, BOOL * _Nonnull stop) {
        YSFGoodsView6 *goodView = [YSFGoodsView6 new];
        goodView.ysf_frameTop = offsetY;
        goodView.ysf_frameHeight = 80;
        goodView.ysf_frameLeft = 0;
        goodView.ysf_frameWidth = width;
        goodView.goods = goods;
        [cell addSubview:goodView];
        [goodView addTarget:self action:@selector(onClickGoods:) forControlEvents:UIControlEventTouchUpInside];
        
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
        goodName.ysf_frameTop = 6;
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
        goodName.ysf_frameHeight = 40;
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
    
    cell.ysf_frameHeight = offsetY;
    return cell;
}

- (void)onClickGoods:(YSFGoodsView6 *)goodsView
{
    [self.delegate onTapCell:goodsView.goods];
}

@end


@interface YSFMoreOrderListViewController () <UITableViewDelegate, UITableViewDataSource,
                                                YSF_NIMSystemNotificationManagerDelegate, YSFCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray *allShops;
@property (nonatomic, strong) YSFAction *action;

@end

@implementation YSFMoreOrderListViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _allShops = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSFRGBA(0x000000, 0.18);
    _action = _orderList.action;
    [_allShops addObjectsFromArray:_orderList.shops];
    [self makeMainView];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
}

-(void)makeMainView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 99.5, YSFUIScreenWidth, self.view.bounds.size.height - 110) style:UITableViewStylePlain];
    _tableView.allowsSelection = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[YSFOrderCell class] forCellReuseIdentifier:kYSFOrderCell];
    
    //刷新控件
    YSFRefreshAutoNormalFooter *footer = [YSFRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        YSFQueryOrderListRequest *request = [YSFQueryOrderListRequest new];
        request.target = _action.target;
        request.params = _action.params;
        [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
            YSFLogApp(@"queryOrderListRequest error:%@", error);
        }];
    }];
    
    [footer setTitle:@"加载中" forState:YSFRefreshStateRefreshing];
    [footer setTitle:@"  上拉加载更多" forState:YSFRefreshStateIdle];
    
    footer.stateLabel.font = [UIFont systemFontOfSize:13.0];
    footer.stateLabel.textColor = YSFRGB(0x999999);
    _tableView.ysf_footer = footer;
    
    [_tableView.ysf_footer beginRefreshing];
    
    UIView *title = [UIView new];
    title.backgroundColor = [UIColor whiteColor];
    title.ysf_frameWidth = YSFUIScreenWidth;
    title.ysf_frameHeight = 32;
    title.ysf_frameTop = 80;
    [self.view addSubview:title];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = _orderList.label;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.ysf_frameWidth = title.ysf_frameWidth - 50;
    titleLabel.ysf_frameHeight = title.ysf_frameHeight;
    titleLabel.ysf_frameLeft = 10;
    [title addSubview:titleLabel];
    
    UIButton *close = [UIButton new];
    [close setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    close.ysf_frameHeight = title.ysf_frameHeight;
    close.ysf_frameWidth = 32;
    close.ysf_frameRight = YSFUIScreenWidth;
    [close addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [title addSubview:close];
    
    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameTop = title.ysf_frameHeight - 0.5;
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 0;
    splitLine.ysf_frameWidth = YSFUIScreenWidth;
    [title addSubview:splitLine];
}

- (void)onClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@",content);
    
    //平台电商时sender就等于shopId，目前服务器这样处理
    NSString *shopId = notification.sender;
    if (!shopId) {
        shopId = @"-1";
    }
    
    id object =  [YSFCustomSystemNotificationParser parse:content];
    if ([object isKindOfClass:[YSFQueryOrderListResponse class]])
    {
        YSFQueryOrderListResponse *response = (YSFQueryOrderListResponse *)object;
        if (response.orderList.shops.count > 0) {
            _action = response.orderList.action;
            [_allShops addObjectsFromArray:response.orderList.shops];
            [_tableView reloadData];
        }
        else {
            [(YSFRefreshAutoNormalFooter *)_tableView.ysf_footer setTitle:response.orderList.label forState:YSFRefreshStateIdle];
        }

        [_tableView.ysf_footer endRefreshing];
    }
}

#pragma tableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSFShop *shop = [_allShops objectAtIndex:indexPath.row];
    YSFOrderCell *cell = [YSFOrderCell new];
    UIView *view = [cell createShopCell:self.view.ysf_frameWidth shop:shop];
    return view.ysf_frameHeight + 10;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allShops.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSFOrderCell* cell = [tableView dequeueReusableCellWithIdentifier:kYSFOrderCell];
    [cell refresh:[_allShops objectAtIndex:indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (void)onTapCell:(YSFGoods *)goods
{
    if (_tapGoodsCallback) {
        _tapGoodsCallback(goods);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

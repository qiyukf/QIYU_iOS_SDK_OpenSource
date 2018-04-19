#import "YSFMoreOrderListViewController.h"
#import "MJRefresh.h"
#import "YSFBotQueryRequest.h"
#import "YSFBotQueryResponse.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFOrderListContentView.h"
#import "UIImageView+YSFWebCache.h"

#define cellHeight 70.0;
#define onlineSessionCellReuseIdentify @"OnlineSessionCell"
#define callCenterCellReuseIdentify @"CallCenterCell"
#define kYSFOrderCell @"YSFOrderCell"
#define kYSFFlightListItemCell @"YSFFlightListItemCell"

@protocol YSFCellDelegate <NSObject>

@optional

- (void)onTapCell:(id)itemData;

@end


@interface YSFItemCell : UITableViewCell

@property (nonatomic, strong) id cellData;
@property (nonatomic, weak)   id<YSFCellDelegate> delegate;

- (void)refresh:(YSFShop *)shop;

@end

@implementation YSFItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    
    return self;
}

- (void)refresh:(id)cellData
{
    self.cellData = cellData;
    [self ysf_removeAllSubviews];
    UIView *view = [_cellData createCell:YSFUIScreenWidth eventHander:self];
    view.ysf_frameTop = 10;
    [self addSubview:view];
}

- (void)onClickItem:(YSFCellView *)cellView
{
    [self.delegate onTapCell:cellView.itemData];
}

@end


@interface YSFMoreOrderListViewController () <UITableViewDelegate, UITableViewDataSource,
                                                YSF_NIMSystemNotificationManagerDelegate, YSFCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray *tableDataSource;

@end

@implementation YSFMoreOrderListViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _tableDataSource = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSFRGBA(0x000000, 0.7);
    if (_originalData) {
        [_tableDataSource addObjectsFromArray:_originalData];
    }
    [self makeMainView];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
}

-(void)makeMainView
{
    UIView *blank = [UIView new];
    blank.ysf_frameWidth = YSFUIScreenWidth;
    blank.ysf_frameHeight = 80;
    [self.view addSubview:blank];
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    singleTapRecognizer.delaysTouchesEnded = NO;
    [blank addGestureRecognizer:singleTapRecognizer];
    
    CGFloat offsetY = 0;
    CGFloat height = self.view.bounds.size.height;
    if (_showTop) {
        UIView *title = [UIView new];
        title.backgroundColor = [UIColor whiteColor];
        title.ysf_frameWidth = YSFUIScreenWidth;
        title.ysf_frameHeight = 32;
        title.ysf_frameTop = 80;
        [self.view addSubview:title];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = _titleString;
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
    
        offsetY = title.ysf_frameBottom - 0.5;
        height -= title.ysf_frameBottom;
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, offsetY, YSFUIScreenWidth, height) style:UITableViewStyleGrouped];
    _tableView.allowsSelection = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[YSFItemCell class] forCellReuseIdentifier:kYSFOrderCell];
    
    if (_action != nil && _action.target.length > 0 && _action.params.length > 0) {
        __weak typeof(self) weakSelf = self;
        YSFRefreshAutoNormalFooter *footer = [YSFRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            YSFQueryOrderListRequest *request = [YSFQueryOrderListRequest new];
            request.target = weakSelf.action.target;
            request.params = weakSelf.action.params;
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
    }
    [self.view addSubview:_tableView];
}

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    id object =  [YSFCustomSystemNotificationParser parse:content shopId:shopId];
    if ([object isKindOfClass:[YSFBotQueryResponse class]])
    {
        YSFBotQueryResponse *response = (YSFBotQueryResponse *)object;
        if ([response.botQueryData isKindOfClass:[YSFOrderList class]]) {
            YSFOrderList *orderList = (YSFOrderList *)(response.botQueryData);
            if (orderList.shops.count > 0) {
                _action = orderList.action;
                [_tableDataSource addObjectsFromArray:orderList.shops];
                [_tableView reloadData];
            }
            else {
                [(YSFRefreshAutoNormalFooter *)_tableView.ysf_footer setTitle:orderList.label forState:YSFRefreshStateIdle];
            }
        }
        else if ([response.botQueryData isKindOfClass:[YSFFlightList class]]) {
            YSFFlightList *flightList = (YSFFlightList *)(response.botQueryData);
            if (flightList.detail != nil)  {
                if (_tableDataSource.count > 0 && flightList.detail.flightDetailItems.count > 0
                    && ![_tableDataSource[0] isKindOfClass:[flightList.detail.flightDetailItems[0] class]]) {
                    return;
                }
                self.navigationItem.title = flightList.detail.label;
                _action = nil;
                [_tableDataSource addObjectsFromArray:flightList.detail.flightDetailItems];
                [_tableView reloadData];
                _tableView.ysf_footer = nil;
            }
            else {
                if (flightList.fieldItems.count > 0) {
                    if (_tableDataSource.count > 0 && flightList.fieldItems.count > 0
                        && ![_tableDataSource[0] isKindOfClass:[flightList.fieldItems[0] class]]) {
                        return;
                    }
                    _action = flightList.action;
                    [_tableDataSource addObjectsFromArray:flightList.fieldItems];
                    [_tableView reloadData];
                }
                else {
                    [(YSFRefreshAutoNormalFooter *)_tableView.ysf_footer setTitle:@"没有更多数据啦" forState:YSFRefreshStateIdle];
                }
            }
        }

        [_tableView.ysf_footer endRefreshing];
    }
}

- (void)onTapCell:(id)itemData
{
    BOOL close = NO;
    if (_tapItemCallback) {
        close = _tapItemCallback(itemData);
    }
    if (close) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma tableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id itemData = nil;
    if ([_tableDataSource[0] isKindOfClass:[NSArray class]]) {
        itemData = _tableDataSource[indexPath.section][indexPath.row];
    }
    else {
        itemData = _tableDataSource[indexPath.row];
    }
    
    UIView *view = [itemData createCell:YSFUIScreenWidth eventHander:nil];

    return view.ysf_frameHeight + 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_tableDataSource.count > 1 && [_tableDataSource[0] isKindOfClass:[NSArray class]]) {
        return _tableDataSource.count;
    }
    else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableDataSource.count > 1 && [_tableDataSource[0] isKindOfClass:[NSArray class]]) {
        return ((NSArray *)_tableDataSource[section]).count;
    }
    else {
        return _tableDataSource.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSFItemCell* cell = [tableView dequeueReusableCellWithIdentifier:kYSFOrderCell];
    id dataItem = nil;
    if ([_tableDataSource[0] isKindOfClass:[NSArray class]]) {
        dataItem = _tableDataSource[indexPath.section][indexPath.row];
    }
    else {
        dataItem = _tableDataSource[indexPath.row];
    }
    [cell refresh:dataItem];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

@end

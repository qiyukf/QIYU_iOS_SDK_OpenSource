#import "YSFActionBar.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"

@implementation YSFActionInfo
@end


@interface YSFActionBar()

@property (nonatomic,strong)    UIView *splitLine;
@property (nonatomic,strong)    UIScrollView *scrollView;

@end

@implementation YSFActionBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YSFRGB(0xffffff);
    }
    return self;
}

- (void)setActionInfoArray:(NSArray *)actionInfoArray
{
    _actionInfoArray = actionInfoArray;
    [self ysf_removeAllSubviews];
    UIView *tmpView = [UIView new];
    _splitLine = tmpView;
    _splitLine.backgroundColor = YSFRGB(0xd8d8d8);
    [self addSubview:_splitLine];
    
    _scrollView = [UIScrollView new];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    __block UIButton *button = nil;
    __block CGFloat right = 0;
    [actionInfoArray enumerateObjectsUsingBlock:^(YSFActionInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        button = [[UIButton alloc] init];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [button addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.layer.borderColor = [QYCustomUIConfig sharedInstance].actionButtonBorderColor.CGColor;
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 0.5;
        [button setTitleColor:[QYCustomUIConfig sharedInstance].actionButtonTextColor forState:UIControlStateNormal];
        [button setTitle:obj.label forState:UIControlStateNormal];
        [button sizeToFit];
        button.ysf_frameWidth += 20;
        button.ysf_frameTop = 10;
        button.ysf_frameLeft = right + 10;
        button.ysf_frameHeight = 22;
        button.tag = idx;
        [_scrollView addSubview:button];
        
        right = button.ysf_frameRight;
    }];
    right += 10;
    _scrollView.contentSize = CGSizeMake(right, _scrollView.ysf_frameHeight);
}

- (void)onClickAction:(id)sender
{
    YSFActionInfo *accountInfo = [_actionInfoArray objectAtIndex:((UIView *)sender).tag];
    if (_selectActionCallback) {
        _selectActionCallback(accountInfo);
    }
}

- (void)layoutSubviews
{
    _splitLine.ysf_frameHeight = 1;
    _splitLine.ysf_frameWidth = self.ysf_frameWidth;
    _scrollView.ysf_frameWidth = self.ysf_frameWidth;
    _scrollView.ysf_frameHeight = self.ysf_frameHeight;
}

@end

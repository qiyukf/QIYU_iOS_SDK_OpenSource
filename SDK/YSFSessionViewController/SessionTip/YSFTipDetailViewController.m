#import "YSFTipDetailViewController.h"


@interface YSFTipDetailViewController ()

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end


@implementation YSFTipDetailViewController

- (instancetype)initWithDetailText:(NSString *)text
{
    if (self = [super init])
    {
        _detailText = text;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [UIScrollView new];
    _scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.view addSubview:_scrollView];

    _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailLabel.numberOfLines = 0;
    _detailLabel.text = _detailText;
    _detailLabel.textColor = YSFRGB(0x222222);
    [_scrollView addSubview:_detailLabel];
}

- (void)viewDidLayoutSubviews
{
    _scrollView.ysf_frameWidth = self.view.ysf_frameWidth;
    _scrollView.ysf_frameHeight = self.view.ysf_frameHeight;
    _detailLabel.ysf_frameWidth = _scrollView.ysf_frameWidth - 40;
    [_detailLabel sizeToFit];
    
    _scrollView.contentSize = CGSizeMake(_detailLabel.ysf_frameWidth, _detailLabel.ysf_frameHeight);
}

@end




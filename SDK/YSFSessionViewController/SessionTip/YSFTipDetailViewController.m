#import "YSFTipDetailViewController.h"
#import "YSFTools.h"


@interface YSFTipDetailViewController ()

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end


@implementation YSFTipDetailViewController
- (instancetype)initWithDetailText:(NSString *)text {
    if (self = [super init]) {
        _detailText = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.view addSubview:_scrollView];

    _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailLabel.numberOfLines = 0;
    _detailLabel.text = _detailText;
    _detailLabel.textColor = YSFRGB(0x222222);
    _detailLabel.font = [UIFont systemFontOfSize:16.0];
    [_scrollView addSubview:_detailLabel];
}

- (void)viewDidLayoutSubviews {
    _scrollView.frame = self.view.bounds;
    
    NSDictionary *dict = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]};
    CGSize size = [_detailText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds) - 40, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:dict
                                            context:nil].size;
    _detailLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 40, ROUND_SCALE(size.height + 1));
    
    _scrollView.contentSize = _detailLabel.bounds.size;
}

@end




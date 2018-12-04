#import "YSFActionBar.h"
#import "QYCustomUIConfig.h"
#import "YSFApiDefines.h"

@implementation YSFActionInfo

+ (YSFActionInfo *)dataByJson:(NSDictionary *)dict
{
    YSFActionInfo *actionInfo = [[YSFActionInfo alloc] init];
    actionInfo.action = [dict ysf_jsonInteger:YSFApiKeyAction];
    actionInfo.buttonId = [NSNumber numberWithInteger:[dict ysf_jsonInteger:YSFApiKeyId]];
    actionInfo.title = [dict ysf_jsonString:YSFApiKeyLabel];
    actionInfo.userData = [dict ysf_jsonString:YSFApiKeyUrl];
    return actionInfo;
}
@end


@interface YSFActionBar()

@property (nonatomic, strong) UIView *splitLine;

@end

@implementation YSFActionBar

+ (CGFloat)heightForActionBar
{
    return YSFActionBarHeight;
}

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
    
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
    }
    [_scrollView ysf_removeAllSubviews];
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
        button.layer.borderWidth = 1. / [UIScreen mainScreen].scale;
        [button setTitleColor:[QYCustomUIConfig sharedInstance].actionButtonTextColor forState:UIControlStateNormal];
        [button setTitle:obj.title forState:UIControlStateNormal];
        [button sizeToFit];
        button.ysf_frameWidth += 20;
        button.ysf_frameTop = 11;
        button.ysf_frameLeft = right + 10;
        button.ysf_frameHeight = 22;
        button.tag = idx;
        [self.scrollView addSubview:button];
        
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
    _splitLine.ysf_frameHeight = 1. / [UIScreen mainScreen].scale;
    _splitLine.ysf_frameWidth = self.ysf_frameWidth;
    _scrollView.ysf_frameWidth = self.ysf_frameWidth;
    _scrollView.ysf_frameHeight = self.ysf_frameHeight;
}

@end

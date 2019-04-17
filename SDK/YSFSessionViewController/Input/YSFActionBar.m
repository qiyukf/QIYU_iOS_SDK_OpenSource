#import "YSFActionBar.h"
#import "QYCustomUIConfig.h"
#import "YSFApiDefines.h"
#import "YSFTools.h"


@implementation YSFActionInfo
+ (YSFActionInfo *)dataByJson:(NSDictionary *)dict {
    YSFActionInfo *actionInfo = [[YSFActionInfo alloc] init];
    actionInfo.action = [dict ysf_jsonInteger:YSFApiKeyAction];
    actionInfo.buttonId = [NSNumber numberWithInteger:[dict ysf_jsonInteger:YSFApiKeyId]];
    actionInfo.title = [dict ysf_jsonString:YSFApiKeyLabel];
    actionInfo.userData = [dict ysf_jsonString:YSFApiKeyUrl];
    return actionInfo;
}
@end


@interface YSFActionBar()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *buttonArray;

@end


@implementation YSFActionBar
+ (CGFloat)heightForActionBar {
    return YSFActionBarHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YSFRGB(0xffffff);
        
        [self initLineView];
        [self initScrollView];
    }
    return self;
}

- (void)initLineView {
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = YSFRGB(0xd8d8d8);
    [self addSubview:_lineView];
}

- (void)initScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)setActionInfoArray:(NSArray *)actionInfoArray {
    _actionInfoArray = actionInfoArray;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat distance = ROUND_SCALE(width * 0.3);
    [_scrollView ysf_removeAllSubviews];
    
    __block CGFloat right = distance;
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:[actionInfoArray count]];
    __weak typeof(self) weakSelf = self;
    [actionInfoArray enumerateObjectsUsingBlock:^(YSFActionInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [[UIButton alloc] init];
        button.alpha = 0;
        button.tag = idx;
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitle:obj.title forState:UIControlStateNormal];
        [button setTitleColor:[QYCustomUIConfig sharedInstance].actionButtonTextColor forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        button.layer.borderColor = [QYCustomUIConfig sharedInstance].actionButtonBorderColor.CGColor;
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1. / [UIScreen mainScreen].scale;
        
        [button sizeToFit];
        button.ysf_frameWidth = ROUND_SCALE(button.ysf_frameWidth + 20);
        button.ysf_frameHeight = 22;
        button.ysf_frameTop = 11;
        button.ysf_frameLeft = ROUND_SCALE(right + 10);
        [button addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.scrollView addSubview:button];
        
        [array addObject:button];
        
        right = button.ysf_frameRight;
    }];
    right += 10;
    _scrollView.contentSize = CGSizeMake(ROUND_SCALE(right - distance), YSFActionBarHeight);
    _scrollView.contentOffset = CGPointZero;
    
    self.buttonArray = array;
    
    //增加推入动效
    if ([self.buttonArray count]) {
        NSTimeInterval delay = 0;
        for (UIButton *button in self.buttonArray) {
            if ((button.ysf_frameRight - distance) > (width * 1.5)) {
                button.alpha = 1;
                button.ysf_frameLeft -= distance;
            } else {
                button.alpha = 0;
                [UIView animateWithDuration:0.5
                                      delay:delay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     button.alpha = 1;
                                     button.ysf_frameLeft -= distance;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                 }];
                delay += 0.2;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _lineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1. / [UIScreen mainScreen].scale);
    _scrollView.frame = self.bounds;
}

- (void)onClickAction:(id)sender {
    YSFActionInfo *accountInfo = [_actionInfoArray objectAtIndex:((UIView *)sender).tag];
    if (_selectActionCallback) {
        _selectActionCallback(accountInfo);
    }
}

@end

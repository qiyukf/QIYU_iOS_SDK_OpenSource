#import "YSFBypassViewController.h"
#import "YSFEvaluationRequest.h"
#import "NSDictionary+YSFJson.h"
#import "UIControl+BlocksKit.h"
#import "UIScrollView+YSFKit.h"
#import "QYCustomUIConfig.h"

@interface YSFBypassViewController()

@property (nonatomic, strong) YSFKFBypassNotification *bypassNotification;
@property (nonatomic, copy)  ByPassCallback callback;
@property (nonatomic,strong) UIImageView *imagePanel;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *evaluationClose;
@property (nonatomic,strong) UIView *splitLine;

@end


@implementation YSFBypassViewController

- (instancetype)initWithByPassNotificatioin:(YSFKFBypassNotification *)bypassNotification
                         callback:(ByPassCallback)callback
{
    self  = [super init];
    if (self) {
        _bypassNotification = bypassNotification;
        _callback = callback;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = YSFColorFromRGBA(0x000000, 0.5);
    _imagePanel = [[UIImageView alloc] init];
    _imagePanel.userInteractionEnabled = YES;
    _imagePanel.backgroundColor = YSFColorFromRGB(0xffffff);
    [self.view addSubview:_imagePanel];
    if ([QYCustomUIConfig sharedInstance].bypassDisplayMode == QYBypassDisplayModeBottom) {
        _imagePanel.ysf_frameWidth = YSFUIScreenWidth;
    }
    else {
        _imagePanel.ysf_frameLeft = 35;
        _imagePanel.ysf_frameWidth = YSFUIScreenWidth - 70;
        _imagePanel.layer.cornerRadius = 6;
    }
    
    _evaluationClose = [[UIButton alloc] initWithFrame:CGRectZero];
    [_evaluationClose setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    [_evaluationClose addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePanel addSubview:_evaluationClose];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.text = _bypassNotification.message;
    _tipLabel.font = [UIFont systemFontOfSize:15];
    _tipLabel.textColor = YSFRGB(0x222222);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [_imagePanel addSubview:_tipLabel];
    
    _splitLine = [UIView new];
    _splitLine.backgroundColor = YSFRGB(0xe6e6e6);
    _splitLine.ysf_frameTop = 44;
    _splitLine.ysf_frameHeight = 0.5;
    _splitLine.ysf_frameLeft = 0;
    _splitLine.ysf_frameWidth = YSFUIScreenWidth;
    [_imagePanel addSubview:_splitLine];
    
    _scrollView = [UIScrollView new];
    [_imagePanel addSubview:_scrollView];
    
    __weak typeof(self) weakSelf = self;
    [_bypassNotification.entries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entryString = [dict objectForKey:YSFApiKeyLabel];
        UIButton *entry = [[UIButton alloc] init];
        [entry setTitle:entryString forState:UIControlStateNormal];
        entry.titleLabel.font = [UIFont systemFontOfSize:15];
        [entry setTitleColor:YSFRGB(0x222222) forState:UIControlStateNormal];
        entry.titleLabel.textAlignment = NSTextAlignmentCenter;
        entry.ysf_frameWidth = weakSelf.imagePanel.ysf_frameWidth;
        entry.ysf_frameHeight = 44;
        entry.ysf_frameTop = idx * 44;
        [entry ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (weakSelf.callback) {
                    weakSelf.callback(YES, dict);
                }
            }];
        } forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.scrollView addSubview:entry];
        
        UIView *splitLine = [UIView new];
        splitLine.backgroundColor = YSFRGB(0xe6e6e6);
        splitLine.ysf_frameTop = [entry ysf_frameBottom];
        splitLine.ysf_frameHeight = 0.5;
        splitLine.ysf_frameLeft = 0;
        splitLine.ysf_frameWidth = YSFUIScreenWidth;
        [weakSelf.scrollView addSubview:splitLine];
    }];
}

- (void)viewDidLayoutSubviews
{
    NSUInteger maxHeight = _bypassNotification.entries.count+1;
    if (maxHeight > 7) {
        maxHeight = 7;
    }
    _imagePanel.ysf_frameHeight = maxHeight * 44;
    if ([QYCustomUIConfig sharedInstance].bypassDisplayMode == QYBypassDisplayModeBottom) {
        _imagePanel.ysf_frameWidth = self.view.ysf_frameWidth;
        _imagePanel.ysf_frameBottom = self.view.ysf_frameBottom;
        if (@available(iOS 11, *)) {
            _imagePanel.ysf_frameBottom -= self.view.safeAreaInsets.bottom;
        }
    }
    else {
        _imagePanel.ysf_frameLeft = 35;
        _imagePanel.ysf_frameWidth = self.view.ysf_frameWidth - 70;
        _imagePanel.ysf_frameCenterY = self.view.ysf_frameCenterY;
    }
    _splitLine.ysf_frameWidth = _imagePanel.ysf_frameWidth;
    _tipLabel.ysf_frameWidth = _imagePanel.ysf_frameWidth;
    _tipLabel.ysf_frameHeight = 44;

    _scrollView.ysf_frameWidth = _imagePanel.ysf_frameWidth;
    _scrollView.ysf_frameTop = _tipLabel.ysf_frameBottom;
    _scrollView.ysf_frameHeight = _imagePanel.ysf_frameHeight - _tipLabel.ysf_frameHeight;
    
    _evaluationClose.ysf_frameWidth = 44;
    _evaluationClose.ysf_frameHeight = 44;
    _evaluationClose.ysf_frameRight = _imagePanel.ysf_frameWidth;

    _scrollView.contentSize = CGSizeMake(_imagePanel.ysf_frameWidth, _bypassNotification.entries.count * 44);
}

- (void)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (_callback) {
            _callback(NO, nil);
        }
    }];
}

@end

#import "YSFEvaluationViewController.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFEvaluationResult.h"
#import "YSFKeyboardManager.h"
#import "YSFEvaluationRequest.h"
#import "NSDictionary+YSFJson.h"
#import "UIControl+BlocksKit.h"
#import "UIScrollView+YSFKit.h"
#import "NSArray+YSF.h"
#import "QYSDK_Private.h"
#import "YSFEvaluationData.h"
#import "YSFMacro.h"

static CGFloat kEvaluationContentPortraitHeight = 377;
static CGFloat kEvaluationContentLandscapeHeight = 220;
static CGFloat kEvaluationButtonTitleInset_Top = 70;
static CGFloat kEvaluationButtonTitleInset_Left = -40;
static CGFloat kEvaluationTitleHeight = 40;
static CGFloat kEvaluationCloseSize = 40;
static CGFloat kEvaluationSatisButtonTop = 20;
static CGFloat kEvaluationSatisButtonWidth = 60;
static CGFloat kEvaluationTagViewMargin = 16;
static CGFloat kEvaluationTagViewTop = 90;
static CGFloat kEvaluationTagButtonMargin = 10;
static CGFloat kEvaluationTagButtonGap = 10;
static CGFloat kEvaluationSubmiteHeight = 70;
static CGFloat kEvaluationSubmiteButtonHeight = 42;

static CGFloat kEvaluationTextViewHeight = 62;
static CGFloat kEvaluationTextViewDefaultTop = 110;


typedef NS_ENUM(NSInteger, YSFEvaluationSubmitType) {
    YSFEvaluationSubmitTypeEnable = 0,  //提交，可点击
    YSFEvaluationSubmitTypeUnable,      //提交，不可点击
    YSFEvaluationSubmitTypeSubmitting,  //提交中，不可点击
};


@implementation YSFEvaluationCommitData

+ (instancetype)instanceByDict:(NSDictionary *)dict {
    YSFEvaluationCommitData *data = [[YSFEvaluationCommitData alloc] init];
    data.type = [dict ysf_jsonInteger:YSFApiKeyType];
    data.title = [dict ysf_jsonString:YSFApiKeyTitle];
    data.tagList = [dict ysf_jsonArray:YSFApiKeyTagList];
    data.content = [dict ysf_jsonString:YSFApiKeyContent];
    return data;
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.type) forKey:YSFApiKeyType];
    [dict setValue:YSFStrParam(self.title) forKey:YSFApiKeyTitle];
    if (self.tagList) {
        [dict setValue:self.tagList forKey:YSFApiKeyTagList];
    }
    [dict setValue:YSFStrParam(self.content) forKey:YSFApiKeyContent];
    return dict;
}

@end


@interface YSFEvaluationViewController() <YSFKeyboardObserver, UIAlertViewDelegate, UITextViewDelegate, YSF_NIMSystemNotificationManagerDelegate>

@property (nonatomic, strong) YSFEvaluationData *evaluationData;    //评价数据
@property (nonatomic, copy) evaluationCallback evaluationCallback;  //结果回调
@property (nonatomic, strong) YSFEvaluationCommitData *lastResult;  //上一次评价结果
@property (nonatomic, assign) BOOL modifyEnable;                    //是否能修改评价
@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *shopId;

@property (nonatomic, strong) UIView *contentView;          //内容区域
@property (nonatomic, strong) UIView *topLineView1;         //分割线
@property (nonatomic, strong) UILabel *titleLabel;          //标题
@property (nonatomic, strong) UIButton *closeButton;        //关闭按钮
@property (nonatomic, strong) UIView *topLineView2;         //分割线
@property (nonatomic, strong) UIScrollView *scrollView;     //滚动区域
@property (nonatomic, strong) NSMutableArray *satisButtons; //满意度按钮集合
@property (nonatomic, strong) NSMutableArray *tagViews;     //标签视图集合
@property (nonatomic, strong) UITextView *textView;         //备注输入区域
@property (nonatomic, strong) UILabel *placeholderLabel;    //备注默认
@property (nonatomic, strong) UIView *bottomLineView;       //分割线
@property (nonatomic, strong) UIButton *submitButton;       //提交按钮

@property (nonatomic, strong) UIButton *selectedButton;      //选中按钮
@property (nonatomic, strong) UIView *selectedTagView;       //选中标签视图
@property (nonatomic, strong) YSFEvaluationTag *selectedTag; //选中tag数据

@property (nonatomic, assign) CGRect kbFrame;

@end


@implementation YSFEvaluationViewController
- (void)dealloc {
    [[YSFKeyboardManager defaultManager] removeObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (instancetype)initWithEvaluationData:(YSFEvaluationData *)evaluationData
                      evaluationResult:(YSFEvaluationCommitData *)lastResult
                                shopId:(NSString *)shopId
                             sessionId:(long long)sessionId
                          modifyEnable:(BOOL)modifyEnable
                    evaluationCallback:(evaluationCallback)evaluationCallback {
    self = [super init];
    if (self) {
        _evaluationData = evaluationData;
        if (!_evaluationData) {
            _evaluationData = [YSFEvaluationData makeDefaultData];
        } else if (!_evaluationData.tagArray || ([_evaluationData.tagArray count] == 0)) {
            YSFEvaluationTag *tag1 = [[YSFEvaluationTag alloc] init];
            tag1.name = @"满意";
            tag1.score = 100;
            
            YSFEvaluationTag *tag2 = [[YSFEvaluationTag alloc] init];
            tag2.name = @"不满意";
            tag2.score = 1;
            
            _evaluationData.tagArray = @[tag1, tag2];
        }
        _lastResult = lastResult;
        _shopId = shopId;
        _sessionId = sessionId;
        _modifyEnable = modifyEnable;
        _evaluationCallback = evaluationCallback;
        _kbFrame = CGRectZero;
        
        _satisButtons = [NSMutableArray array];
        _tagViews = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[YSFKeyboardManager defaultManager] addObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    __weak typeof(self) weakSelf = self;
    self.view.backgroundColor = YSFColorFromRGBA(0x000000, 0.5);
    CGFloat lineWidth = (1. / [UIScreen mainScreen].scale);
    //contentView
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.ysf_frameWidth = self.view.ysf_frameWidth;
    _contentView.ysf_frameHeight = kEvaluationContentPortraitHeight;
    _contentView.ysf_frameBottom = self.view.ysf_frameBottom;
    [self.view addSubview:_contentView];
    //topLineView1
    _topLineView1 = [[UIView alloc] init];
    _topLineView1.backgroundColor = YSFColorFromRGB(0xdcdcdc);
    //titleLabel
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = YSFColorFromRGB(0xf1f1f1);
    _titleLabel.text = @"请对我们的服务做出评价";
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = YSFRGB(0x222222);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_titleLabel];
    //closeButton
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_closeButton];
    //topLineView2
    _topLineView2 = [[UIView alloc] init];
    _topLineView2.backgroundColor = YSFColorFromRGB(0xdcdcdc);
    //scrollView
    _scrollView = [[UIScrollView alloc] init];
    [_contentView addSubview:_scrollView];
    //satisButtons & tagViews
    if (_evaluationData.tagArray.count) {
        for (YSFEvaluationTag *tag in _evaluationData.tagArray) {
            //1.根据tag数据创建相应的满意度按钮，并放入satisButtons数组
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = tag.type;
            UIImage *image = [self getButtonNormalImageForTagType:tag.type];
            [button setImage:image forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateHighlighted];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
            [button setTitle:tag.name forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            button.titleEdgeInsets = UIEdgeInsetsMake(kEvaluationButtonTitleInset_Top, kEvaluationButtonTitleInset_Left, 0, 0);
            button.titleLabel.layer.cornerRadius = 4.0;
            button.titleLabel.layer.masksToBounds = YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button sizeToFit];
            [button ysf_addEventHandler:^(id sender) {
                [weakSelf onSelect:sender];
            } forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:button];
            //add button to array
            [_satisButtons addObject:button];
            //2.根据tag数据中的tagList创建相应的标签按钮并add到tagView上，最终将tagView放入tagViews数组
            UIView *tagView = [[UIView alloc] initWithFrame:CGRectZero];
            tagView.tag = tag.type;
            for (NSString *tagString in tag.tagList) {
                UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [tagButton setTitle:tagString forState:UIControlStateNormal];
                [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                tagButton.layer.cornerRadius = 10.0;
                tagButton.layer.borderWidth = lineWidth;
                tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
                tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
                tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, kEvaluationTagButtonMargin, 0, kEvaluationTagButtonMargin);
                tagButton.titleLabel.layer.masksToBounds = YES;
                __weak typeof(tagButton) weakTagButton = tagButton;
                [tagButton ysf_addEventHandler:^(id sender) {
                    weakTagButton.selected = !weakTagButton.selected;
                    if (weakTagButton.selected) {
                        weakTagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    } else {
                        weakTagButton.backgroundColor = [UIColor clearColor];
                    }
                    if (weakSelf.lastResult) {
                        [weakSelf updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
                    }
                } forControlEvents:UIControlEventTouchUpInside];
                [tagView addSubview:tagButton];
            }
            tagView.hidden = YES;
            [_scrollView addSubview:tagView];
            //add tagView to array
            [_tagViews addObject:tagView];
        }
    }
    //textView
    _textView = [[UITextView alloc] init];
    _textView.delegate = self;
    _textView.textColor = [UIColor blackColor];
    _textView.font = [UIFont systemFontOfSize:13.0];
    _textView.layer.borderColor = YSFColorFromRGB(0xdcdcdc).CGColor;
    _textView.layer.borderWidth = lineWidth;
    _textView.layer.cornerRadius = 3.0;
    [_scrollView addSubview:_textView];
    //placeholderLabel
    _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    _placeholderLabel.text = @"评价备注";
    _placeholderLabel.font = [UIFont systemFontOfSize:13.0];
    [_textView addSubview:_placeholderLabel];
    //bottomLineView
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = YSFColorFromRGB(0xdcdcdc);
    //submitButton
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _submitButton.layer.cornerRadius = 3.0;
    [_submitButton addTarget:self action:@selector(onSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_submitButton];
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeUnable];
    
    [_contentView addSubview:_topLineView1];
    [_contentView addSubview:_topLineView2];
    [_contentView addSubview:_bottomLineView];
    
    [self updateLastResult];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat lineWidth = (1. / [UIScreen mainScreen].scale);
    //contentView
    BOOL isLandscape = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    _contentView.ysf_frameWidth = self.view.ysf_frameWidth;
    _contentView.ysf_frameBottom = self.view.ysf_frameBottom;
    _contentView.ysf_frameHeight = isLandscape ? kEvaluationContentLandscapeHeight : kEvaluationContentPortraitHeight;
    if (!CGRectEqualToRect(_kbFrame, CGRectZero) && _kbFrame.origin.y < CGRectGetHeight(self.view.bounds) && CGRectGetHeight(_kbFrame)) {
        CGRect contentFrame = _contentView.frame;
        contentFrame.origin.y = _kbFrame.origin.y - contentFrame.size.height;
        if (contentFrame.origin.y < YSFStatusBarHeight) {
            contentFrame.origin.y = YSFStatusBarHeight;
            contentFrame.size.height = CGRectGetHeight([UIScreen mainScreen].bounds) - YSFStatusBarHeight - _kbFrame.size.height;
        }
        _contentView.frame = contentFrame;
    }
    //topLineView1
    _topLineView1.ysf_frameWidth = _contentView.ysf_frameWidth;
    _topLineView1.ysf_frameHeight = lineWidth;
    //titleLabel
    _titleLabel.ysf_frameWidth = _contentView.ysf_frameWidth;
    _titleLabel.ysf_frameHeight = kEvaluationTitleHeight;
    //closeButton
    _closeButton.ysf_frameWidth = kEvaluationCloseSize;
    _closeButton.ysf_frameHeight = kEvaluationCloseSize;
    _closeButton.ysf_frameRight = _contentView.ysf_frameWidth;
    //topLineView2
    _topLineView2.ysf_frameWidth = _contentView.ysf_frameWidth;
    _topLineView2.ysf_frameHeight = lineWidth;
    _topLineView2.ysf_frameTop = _titleLabel.ysf_frameBottom;
    //scrollView
    _scrollView.ysf_frameWidth = _contentView.ysf_frameWidth;
    _scrollView.ysf_frameTop = _titleLabel.ysf_frameBottom;
    _scrollView.ysf_frameHeight = CGRectGetHeight(_contentView.frame) - CGRectGetHeight(_titleLabel.frame) - kEvaluationSubmiteHeight;
    //item space
    CGFloat space = 0;
    NSUInteger count = _evaluationData.tagArray.count;
    if (count > 0) {
        space = (_contentView.ysf_frameWidth - kEvaluationSatisButtonWidth * count) / (count + 1);
    }
    //satisButtons
    CGFloat satisButtonBottom = 0;
    for (NSInteger index = 0; index < _satisButtons.count; index++) {
        UIButton *button = [_satisButtons objectAtIndex:index];
        button.ysf_frameTop = kEvaluationSatisButtonTop;
        button.ysf_frameWidth = kEvaluationSatisButtonWidth;
        button.ysf_frameLeft = roundf(space * (index + 1) + kEvaluationSatisButtonWidth * index);
        satisButtonBottom = button.ysf_frameBottom;
    }
    //tagViews
    for (UIView *tagView in _tagViews) {
        tagView.ysf_frameWidth = _contentView.ysf_frameWidth - 2 * kEvaluationTagViewMargin;
        tagView.ysf_frameCenterX = _contentView.ysf_frameCenterX;
        tagView.ysf_frameTop = kEvaluationTagViewTop;
        tagView.ysf_frameHeight = 30;
        
        CGFloat tagButtonRight = 0;
        CGFloat tagButtonBottom = 0;
        CGFloat totalHeight = 0;
        for (UIButton *tagButton in tagView.subviews) {
            [tagButton sizeToFit];
            tagButton.ysf_frameWidth += 2 * kEvaluationTagButtonMargin;
            tagButton.ysf_frameLeft = tagButtonRight + kEvaluationTagButtonGap;
            tagButton.ysf_frameTop = tagButtonBottom + kEvaluationTagButtonGap;
            if (tagButton.ysf_frameRight > tagView.ysf_frameWidth) {
                tagButtonRight = 0;
                tagButtonBottom = tagButtonBottom + tagButton.ysf_frameHeight + kEvaluationTagButtonGap;
                tagButton.ysf_frameLeft = tagButtonRight + kEvaluationTagButtonGap;
                tagButton.ysf_frameTop = tagButtonBottom + kEvaluationTagButtonGap;
            }
            tagButtonRight = tagButton.ysf_frameRight;
            totalHeight = tagButton.ysf_frameBottom;
        }
        tagView.ysf_frameHeight = totalHeight;
    }
    
    //textView
    _textView.ysf_frameWidth = _contentView.ysf_frameWidth - 2 * kEvaluationTagViewMargin;
    _textView.ysf_frameCenterX = _contentView.ysf_frameCenterX;
    _textView.ysf_frameHeight = kEvaluationTextViewHeight;
    if (_selectedTagView) {
        _textView.ysf_frameTop = _selectedTagView.ysf_frameBottom + 20;
        _scrollView.contentSize = CGSizeMake(_contentView.ysf_frameWidth, _textView.ysf_frameBottom + 10);
    } else {
        _textView.ysf_frameTop = kEvaluationTextViewDefaultTop;
        _scrollView.contentSize = CGSizeMake(_contentView.ysf_frameWidth, _textView.ysf_frameBottom + 10);
    }
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    //bottomLineView
    _bottomLineView.ysf_frameWidth = _contentView.ysf_frameWidth;
    _bottomLineView.ysf_frameHeight = lineWidth;
    _bottomLineView.ysf_frameTop = _scrollView.ysf_frameBottom;
    //submitButton
    _submitButton.ysf_frameWidth = _contentView.ysf_frameWidth - 2 * kEvaluationTagViewMargin;
    _submitButton.ysf_frameCenterX = _contentView.ysf_frameCenterX;
    _submitButton.ysf_frameHeight = kEvaluationSubmiteButtonHeight;
    _submitButton.ysf_frameTop = _scrollView.ysf_frameBottom + (kEvaluationSubmiteHeight - kEvaluationSubmiteButtonHeight) / 2;
}

#pragma mark - action
- (void)onSelect:(id)sender {
    [self.view endEditing:YES];
    //clean
    _selectedButton.selected = NO;
    _selectedButton.titleLabel.backgroundColor = [UIColor clearColor];
    _selectedTagView.hidden = YES;
    //selectedButton
    UIButton *button = (UIButton *)sender;
    _selectedButton = button;
    _selectedButton.selected = YES;
    _selectedButton.titleLabel.backgroundColor = YSFColorFromRGB(0x999999);
    //selectedButton animation
    CGAffineTransform oldTransForm =  button.imageView.transform;
    CGAffineTransform transform = CGAffineTransformScale(oldTransForm, 1.2, 1.2);
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        button.imageView.transform = transform;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^{
            button.imageView.transform = oldTransForm;
        } completion:nil];
    }];
    //selectedTagView
    for (UIView *tagView in _tagViews) {
        if (tagView.tag == button.tag) {
            _selectedTagView = tagView;
        }
    }
    _selectedTagView.hidden = NO;
    [_contentView bringSubviewToFront:_selectedTagView];
    
    for (YSFEvaluationTag *tag in _evaluationData.tagArray) {
        if (_selectedButton.tag == tag.type) {
            _selectedTag = tag;
        }
    }
    //submiteButton
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
    
    [self.view setNeedsLayout];
}

- (void)onSubmit:(id)sender {
    if (!_selectedTag) {
        return;
    }
    if (_selectedTag.commentRequired && _textView.text.length == 0) {
        [self showToast:@"请填写评价备注"];
        return;
    }
    NSArray *selectedTags = [self getSelectedTags];
    if (_selectedTag.tagRequired && (!selectedTags || selectedTags.count == 0)) {
        [self showToast:@"请选择标签"];
        return;
    }
    //start submitting
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeSubmitting];
    
    YSFEvaluationRequest *request = [[YSFEvaluationRequest alloc] init];
    request.score = _selectedTag.score;
    request.remarks = _textView.text;
    request.sessionId = _sessionId;
    request.tagInfos = selectedTags;
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {
        if (error) {
            [weakSelf updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
            [weakSelf showToast:@"网络连接失败，请稍后再试"];
        }
    }];
}

- (NSArray *)getSelectedTags {
    if (!_selectedTag || !_selectedTagView) {
        return nil;
    }
    NSMutableArray *selectedTags = [NSMutableArray array];
    for (UIButton *tagButton in _selectedTagView.subviews) {
        if (tagButton.selected) {
            if (tagButton.titleLabel.text) {
                [selectedTags addObject:tagButton.titleLabel.text];
            }
        }
    }
    return selectedTags;
}

- (void)updateSubmitButtonEnable:(YSFEvaluationSubmitType)type {
    if (type == YSFEvaluationSubmitTypeEnable) {
        _submitButton.enabled = YES;
        [_submitButton setTitle:@"提 交" forState:UIControlStateNormal];
        _submitButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 1);
    } else if (type == YSFEvaluationSubmitTypeUnable) {
        _submitButton.enabled = NO;
        [_submitButton setTitle:@"提 交" forState:UIControlStateNormal];
        _submitButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFEvaluationSubmitTypeSubmitting) {
        _submitButton.enabled = NO;
        [_submitButton setTitle:@"提交中..." forState:UIControlStateNormal];
        _submitButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    }
}

#pragma mark - close
- (void)onClose:(id)sender {
    if (_submitButton.enabled) {
        //解决iOS键盘消失动画被打断后闪一下问题
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *title = weakSelf.modifyEnable ? @"是否放弃当前评价" : @"是否放弃当前评价，放弃后不可恢复";
            UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:title
                                                             message:@""
                                                            delegate:weakSelf
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:nil, nil];
            [dialog addButtonWithTitle:@"取消"];
            [dialog addButtonWithTitle:@"确定"];
            [dialog show];
        });
    } else {
        [self closeViewController];
    }
    [self.textView resignFirstResponder];   //否则close评价窗口键盘会抖动
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.textView becomeFirstResponder];
    } else if (buttonIndex == 1) {
        [self closeViewController];
    }
}

- (void)closeViewController {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.evaluationCallback) {
            weakSelf.evaluationCallback(NO, nil);
        }
    }];
}

#pragma mark - YSF_NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification {
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@", content);
    
    //平台电商时sender等于shopId (目前服务器如此处理)
    NSString *shopId = notification.sender;
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    //解析
    id object =  [YSFCustomSystemNotificationParser parse:content shopId:shopId];
    
    if ([object isKindOfClass:[YSFEvaluationResult class]]) {
        YSFEvaluationResult *result = (YSFEvaluationResult *)object;
        if (result.code == YSFCodeServiceEvaluationAllow || result.code == YSFCodeServiceEvaluationAlreadyDone) {
            if (result.sessionId == _sessionId) {
                YSFEvaluationCommitData *commitData = [[YSFEvaluationCommitData alloc] init];
                commitData.type = _selectedTag.type;
                commitData.title = _selectedTag.name;
                commitData.tagList = [self getSelectedTags];
                commitData.content = _textView.text;
                NSMutableDictionary *sessionDict = [[[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:_sessionId] mutableCopy];
                if (sessionDict) {
                    [sessionDict setValue:[commitData toDict] forKey:YSFEvaluationKeyResultData];
                    [[[QYSDK sharedSDK] sessionManager] setHistoryEvaluationData:sessionDict shopId:_shopId sessionId:_sessionId];
                }
                
                if (self.evaluationCallback) {
                    self.evaluationCallback(YES, result);
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else if (result.code == YSFCodeServiceEvaluationOverTime) {
            [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
            [self showToast:@"评价已超时，无法进行评价"];
        } else if (result.code == YSFCodeServiceEvaluationNotAllow) {
            [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
            [self showToast:@"评价失败"];
        }
    }
}

#pragma mark - gesture
-(void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

#pragma mark - YSFKeyboardObserver
- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        self.kbFrame = [[YSFKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        [self.view setNeedsLayout];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_scrollView ysf_scrollToBottom:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.hidden = NO;
    }
    
    NSString *nsTextContent = textView.text;
    if (nsTextContent.length > 100) {
        NSString *s = [nsTextContent substringToIndex:100];
        [textView setText:s];
    }
    
    //解决自动上下移动问题
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top);
    if (overflow > 0) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [textView setContentOffset:offset];
    }
    if (self.lastResult) {
        if (![_textView.text isEqualToString:self.lastResult.content]) {
            [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
        }
    }
}

#pragma mark - other
- (void)showToast:(NSString *)toast {
    if (toast.length) {
        [self.contentView ysf_makeToast:toast duration:2 position:YSFToastPositionCenter];
    }
}

- (void)updateLastResult {
    if (self.lastResult) {
        for (UIButton *button in _satisButtons) {
            if (button.tag == self.lastResult.type) {
                [self onSelect:button];
                break;
            }
        }
        
        for (NSString *selectTagString in self.lastResult.tagList) {
            for (UIButton *tagButton in _selectedTagView.subviews) {
                if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                    tagButton.selected = YES;
                    tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                }
            }
        }
        
        if (self.lastResult.content.length) {
            _textView.text = self.lastResult.content;
            _placeholderLabel.hidden = YES;
        }
        [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeUnable];
    }
}

- (UIImage *)getButtonNormalImageForTagType:(YSFEvaluationTagType)tagType {
    if (tagType == YSFEvaluationTagTypeVerySatisfied) {
        return [UIImage ysf_imageInKit:@"icon_evaluation_satisfied1"];
    } else if (tagType == YSFEvaluationTagTypeSatisfied) {
        return [UIImage ysf_imageInKit:@"icon_evaluation_satisfied2"];
    } else if (tagType == YSFEvaluationTagTypeOrdinary) {
        return [UIImage ysf_imageInKit:@"icon_evaluation_satisfied3"];
    } else if (tagType == YSFEvaluationTagTypeDissatisfied) {
        return [UIImage ysf_imageInKit:@"icon_evaluation_satisfied4"];
    } else if (tagType == YSFEvaluationTagTypeVeryDissatisfied) {
        return [UIImage ysf_imageInKit:@"icon_evaluation_satisfied5"];
    } else {
        return nil;
    }
}

@end

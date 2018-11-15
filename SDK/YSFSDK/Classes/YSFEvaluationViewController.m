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

typedef NS_ENUM(NSInteger, YSFEvaluationSubmitType) {
    YSFEvaluationSubmitTypeEnable = 0,  //提交，可点击
    YSFEvaluationSubmitTypeUnable,      //提交，不可点击
    YSFEvaluationSubmitTypeSubmitting,  //提交中，不可点击
};


@implementation YSFEvaluationCommitData

+ (instancetype)instanceByDict:(NSDictionary *)dict {
    YSFEvaluationCommitData *data = [[YSFEvaluationCommitData alloc] init];
    data.title = [dict ysf_jsonString:YSFApiKeyTitle];
    data.tagList = [dict ysf_jsonArray:YSFApiKeyTagList];
    data.content = [dict ysf_jsonString:YSFApiKeyContent];
    return data;
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:YSFStrParam(self.title) forKey:YSFApiKeyTitle];
    if (self.tagList) {
        [dict setValue:self.tagList forKey:YSFApiKeyTagList];
    }
    [dict setValue:YSFStrParam(self.content) forKey:YSFApiKeyContent];
    return dict;
}

@end

@interface YSFEvaluationViewController() <YSFKeyboardObserver, UIAlertViewDelegate, UITextViewDelegate, YSF_NIMSystemNotificationManagerDelegate>

@property (nonatomic, strong) NSDictionary *evaluationDict;
@property (nonatomic, copy) evaluationCallback evaluationCallback;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic,strong) UILabel* placeholderLabel;
@property (nonatomic,strong) UIButton *selectedButton;
@property (nonatomic,strong) UIView *selectedTagListView;
@property (nonatomic,strong) UIButton *submit;
@property (nonatomic,strong) UIImageView *imagePanel;
@property (nonatomic,assign) long long sessionId;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIButton *satisfaction1;
@property (nonatomic,strong) UIButton *satisfaction2;
@property (nonatomic,strong) UIButton *satisfaction3;
@property (nonatomic,strong) UIButton *satisfaction4;
@property (nonatomic,strong) UIButton *satisfaction5;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *tagList1;
@property (nonatomic,strong) UIView *tagList2;
@property (nonatomic,strong) UIView *tagList3;
@property (nonatomic,strong) UIView *tagList4;
@property (nonatomic,strong) UIView *tagList5;
@property (nonatomic,strong) UIButton *evaluationClose;
@property (nonatomic,copy) NSString *shopId;

@property (nonatomic, strong) YSFEvaluationCommitData *lastResult;
@property (nonatomic, assign) BOOL modifyEnable;

@end


@implementation YSFEvaluationViewController

- (instancetype)initWithEvaluationDict:(NSDictionary *)evaluationDict
                      evaluationResult:(YSFEvaluationCommitData *)lastResult
                                shopId:(NSString *)shopId
                             sessionId:(long long)sessionId
                          modifyEnable:(BOOL)modifyEnable
                    evaluationCallback:(evaluationCallback)evaluationCallback {
    self = [super init];
    if (self) {
        _evaluationDict = evaluationDict;
        if (!_evaluationDict || _evaluationDict.count == 0) {
            _evaluationDict = @{ @"满意":@{YSFApiKeyValue:@(100)}, @"不满意":@{YSFApiKeyValue:@(1)} };
        }
        _lastResult = lastResult;
        _shopId = shopId;
        _sessionId = sessionId;
        _modifyEnable = modifyEnable;
        _evaluationCallback = evaluationCallback;
    }
    return self;
}

- (void)dealloc {
    [[YSFKeyboardManager defaultManager] removeObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[YSFKeyboardManager defaultManager] addObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    self.view.backgroundColor = YSFColorFromRGBA(0x000000, 0.5);
    _imagePanel = [[UIImageView alloc] init];
    _imagePanel.userInteractionEnabled = YES;
    _imagePanel.backgroundColor = YSFColorFromRGB(0xffffff);
    _imagePanel.ysf_frameWidth = self.view.ysf_frameWidth;
    _imagePanel.ysf_frameHeight = 377;
    _imagePanel.ysf_frameBottom = self.view.ysf_frameBottom;
    [self.view addSubview:_imagePanel];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.backgroundColor = YSFColorFromRGB(0xf1f1f1);
    _tipLabel.text = @"请对我们的服务做出评价";
    _tipLabel.font = [UIFont systemFontOfSize:15];
    _tipLabel.textColor = YSFRGB(0x222222);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [_imagePanel addSubview:_tipLabel];
    
    _scrollView = [UIScrollView new];
    [_imagePanel addSubview:_scrollView];
    
    _satisfaction1 = [[UIButton alloc] initWithFrame:CGRectZero];
    [_satisfaction1 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied1"] forState:UIControlStateNormal];
    [_satisfaction1 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied1"] forState:UIControlStateHighlighted];
    [_satisfaction1 setTitle:@"非常满意" forState:UIControlStateNormal];
    _satisfaction1.titleLabel.font = [UIFont systemFontOfSize:12];
    _satisfaction1.titleEdgeInsets = UIEdgeInsetsMake(80, -48, 0, 0);
    _satisfaction1.titleLabel.layer.cornerRadius = 4.0;
    _satisfaction1.titleLabel.layer.masksToBounds = YES;
    [_satisfaction1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_satisfaction1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    [_satisfaction1 ysf_addEventHandler:^(id  _Nonnull sender) {
        [weakSelf onSelect:sender selectedTagListView:weakSelf.tagList1];
    } forControlEvents:UIControlEventTouchUpInside];
    _satisfaction1.hidden = YES;
    [_satisfaction1 sizeToFit];
    [_scrollView addSubview:_satisfaction1];
    
    _satisfaction2 = [[UIButton alloc] initWithFrame:CGRectZero];
    [_satisfaction2 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied2"] forState:UIControlStateNormal];
    [_satisfaction2 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied2"] forState:UIControlStateHighlighted];
    [_satisfaction2 setTitle:@"满意" forState:UIControlStateNormal];
    _satisfaction2.titleLabel.font = [UIFont systemFontOfSize:12];
    _satisfaction2.titleEdgeInsets = UIEdgeInsetsMake(80, -38, 0, 0);
    _satisfaction2.titleLabel.layer.cornerRadius = 4.0;
    _satisfaction2.titleLabel.layer.masksToBounds = YES;
    [_satisfaction2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_satisfaction2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_satisfaction2 ysf_addEventHandler:^(id  _Nonnull sender) {
        [weakSelf onSelect:sender selectedTagListView:weakSelf.tagList2];
    } forControlEvents:UIControlEventTouchUpInside];
    _satisfaction2.hidden = YES;
    [_satisfaction2 sizeToFit];
    [_scrollView addSubview:_satisfaction2];
    
    _satisfaction3 = [[UIButton alloc] initWithFrame:CGRectZero];
    [_satisfaction3 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied3"] forState:UIControlStateNormal];
    [_satisfaction3 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied3"] forState:UIControlStateHighlighted];
    [_satisfaction3 setTitle:@"一般" forState:UIControlStateNormal];
    _satisfaction3.titleLabel.font = [UIFont systemFontOfSize:12];
    _satisfaction3.titleEdgeInsets = UIEdgeInsetsMake(80, -38, 0, 0);
    _satisfaction3.titleLabel.layer.cornerRadius = 4.0;
    _satisfaction3.titleLabel.layer.masksToBounds = YES;
    [_satisfaction3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_satisfaction3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_satisfaction3 ysf_addEventHandler:^(id  _Nonnull sender) {
        [weakSelf onSelect:sender selectedTagListView:weakSelf.tagList3];
    } forControlEvents:UIControlEventTouchUpInside];
    _satisfaction3.hidden = YES;
    [_satisfaction3 sizeToFit];
    [_scrollView addSubview:_satisfaction3];
    
    _satisfaction4 = [[UIButton alloc] initWithFrame:CGRectZero];
    [_satisfaction4 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied4"] forState:UIControlStateNormal];
    [_satisfaction4 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied4"] forState:UIControlStateHighlighted];
    [_satisfaction4 setTitle:@"不满意" forState:UIControlStateNormal];
    _satisfaction4.titleLabel.font = [UIFont systemFontOfSize:12];
    _satisfaction4.titleEdgeInsets = UIEdgeInsetsMake(80, -38, 0, 0);
    _satisfaction4.titleLabel.layer.cornerRadius = 4.0;
    _satisfaction4.titleLabel.layer.masksToBounds = YES;
    [_satisfaction4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_satisfaction4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_satisfaction4 ysf_addEventHandler:^(id  _Nonnull sender) {
        [weakSelf onSelect:sender selectedTagListView:weakSelf.tagList4];
    } forControlEvents:UIControlEventTouchUpInside];
    _satisfaction4.hidden = YES;
    [_satisfaction4 sizeToFit];
    [_scrollView addSubview:_satisfaction4];
    
    _satisfaction5 = [[UIButton alloc] initWithFrame:CGRectZero];
    [_satisfaction5 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied5"] forState:UIControlStateNormal];
    [_satisfaction5 setImage:[UIImage ysf_imageInKit:@"icon_evaluation_satisfied5"] forState:UIControlStateHighlighted];
    [_satisfaction5 setTitle:@"非常不满意" forState:UIControlStateNormal];
    _satisfaction5.titleLabel.font = [UIFont systemFontOfSize:12];
    _satisfaction5.titleEdgeInsets = UIEdgeInsetsMake(80, -48, 0, 0);
    _satisfaction5.titleLabel.layer.cornerRadius = 4.0;
    _satisfaction5.titleLabel.layer.masksToBounds = YES;
    [_satisfaction5 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_satisfaction5 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_satisfaction5 ysf_addEventHandler:^(id  _Nonnull sender) {
        [weakSelf onSelect:sender selectedTagListView:weakSelf.tagList5];
    } forControlEvents:UIControlEventTouchUpInside];
    _satisfaction5.hidden = YES;
    [_satisfaction5 sizeToFit];
    [_scrollView addSubview:_satisfaction5];
    
    _tagList1 = [[UIView alloc] initWithFrame:CGRectZero];
    _tagList1.hidden = YES;
    [_scrollView addSubview:_tagList1];
    NSDictionary *dict = [_evaluationDict objectForKey:@"非常满意"];
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *tagListArray = [dict objectForKey:YSFApiKeyTagList];
        for (NSString *tagString in tagListArray) {
            UIButton *tagButton = [UIButton new];
            [tagButton setTitle:tagString forState:UIControlStateNormal];
            [tagButton setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
            tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
            tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagButton.layer.cornerRadius = 10.0;
            tagButton.layer.borderWidth = 0.5;
            tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tagButton.titleLabel.layer.masksToBounds = YES;
            
            __weak typeof(tagButton) weakTagButton = tagButton;
            [tagButton ysf_addEventHandler:^(id  _Nonnull sender) {
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
            [_tagList1 addSubview:tagButton];
        }
    }
    
    _tagList2 = [[UIView alloc] initWithFrame:CGRectZero];
    _tagList2.hidden = YES;
    [_scrollView addSubview:_tagList2];
    dict = [_evaluationDict objectForKey:@"满意"];
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *tagListArray = [dict objectForKey:YSFApiKeyTagList];
        for (NSString *tagString in tagListArray) {
            UIButton *tagButton = [UIButton new];
            [tagButton setTitle:tagString forState:UIControlStateNormal];
            [tagButton setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
            tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
            tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagButton.layer.cornerRadius = 10.0;
            tagButton.layer.borderWidth = 0.5;
            tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tagButton.titleLabel.layer.masksToBounds = YES;
            
            __weak typeof(tagButton) weakTagButton = tagButton;
            [tagButton ysf_addEventHandler:^(id  _Nonnull sender) {
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
            [_tagList2 addSubview:tagButton];
        }
    }
    
    _tagList3 = [[UIView alloc] initWithFrame:CGRectZero];
    _tagList3.hidden = YES;
    [_scrollView addSubview:_tagList3];
    dict = [_evaluationDict objectForKey:@"一般"];
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *tagListArray = [dict objectForKey:YSFApiKeyTagList];
        for (NSString *tagString in tagListArray) {
            UIButton *tagButton = [UIButton new];
            [tagButton setTitle:tagString forState:UIControlStateNormal];
            [tagButton setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
            tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
            tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagButton.layer.cornerRadius = 10.0;
            tagButton.layer.borderWidth = 0.5;
            tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tagButton.titleLabel.layer.masksToBounds = YES;
            
            __weak typeof(tagButton) weakTagButton = tagButton;
            [tagButton ysf_addEventHandler:^(id  _Nonnull sender) {
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
            [_tagList3 addSubview:tagButton];
        }
    }
    
    _tagList4 = [[UIView alloc] initWithFrame:CGRectZero];
    _tagList4.hidden = YES;
    [_scrollView addSubview:_tagList4];
    dict = [_evaluationDict objectForKey:@"不满意"];
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *tagListArray = [dict objectForKey:YSFApiKeyTagList];
        for (NSString *tagString in tagListArray) {
            UIButton *tagButton = [UIButton new];
            [tagButton setTitle:tagString forState:UIControlStateNormal];
            [tagButton setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
            tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
            tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagButton.layer.cornerRadius = 10.0;
            tagButton.layer.borderWidth = 0.5;
            tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tagButton.titleLabel.layer.masksToBounds = YES;
            
            __weak typeof(tagButton) weakTagButton = tagButton;
            [tagButton ysf_addEventHandler:^(id  _Nonnull sender) {
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
            [_tagList4 addSubview:tagButton];
        }
    }
    
    _tagList5 = [[UIView alloc] initWithFrame:CGRectZero];
    _tagList5.hidden = YES;
    [_scrollView addSubview:_tagList5];
    dict = [_evaluationDict objectForKey:@"非常不满意"];
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *tagListArray = [dict objectForKey:YSFApiKeyTagList];
        for (NSString *tagString in tagListArray) {
            UIButton *tagButton = [UIButton new];
            [tagButton setTitle:tagString forState:UIControlStateNormal];
            [tagButton setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
            tagButton.titleLabel.font = [UIFont systemFontOfSize:12];
            tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagButton.layer.cornerRadius = 10.0;
            tagButton.layer.borderWidth = 0.5;
            tagButton.layer.borderColor = YSFRGB(0xcccccc).CGColor;
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [tagButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tagButton.titleLabel.layer.masksToBounds = YES;
            
            __weak typeof(tagButton) weakTagButton = tagButton;
            [tagButton ysf_addEventHandler:^(id  _Nonnull sender) {
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
            [_tagList5 addSubview:tagButton];
        }
    }
    
    _evaluationClose = [[UIButton alloc] initWithFrame:CGRectZero];
    [_evaluationClose setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    [_evaluationClose addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePanel addSubview:_evaluationClose];
    
    _textView = [UITextView new];
    _textView.layer.borderColor = YSFColorFromRGB(0xdcdcdc).CGColor;
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 3.0;
    _textView.delegate = self;
    _textView.textColor = [UIColor blackColor];
    _textView.font = [UIFont systemFontOfSize:13.0];
    [_scrollView addSubview:_textView];
    
    _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    _placeholderLabel.text = @"备注（选填）";
    _placeholderLabel.font = [UIFont systemFontOfSize:13.0];
    [self.textView addSubview:_placeholderLabel];
    
    _submit = [[UIButton alloc] initWithFrame:CGRectZero];
    _submit.layer.cornerRadius = 3.0;
    _submit.titleLabel.font = [UIFont systemFontOfSize:16.0];;
    [_submit addTarget:self action:@selector(onSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePanel addSubview:_submit];
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeUnable];
    
    [self updateLastResult];
}

- (void)viewDidLayoutSubviews
{
    _tipLabel.ysf_frameWidth = _imagePanel.ysf_frameWidth;
    _tipLabel.ysf_frameHeight = 40;
    _satisfaction1.ysf_frameTop = 20;
    _satisfaction1.ysf_frameWidth = 50;
    _satisfaction2.ysf_frameTop = 20;
    _satisfaction2.ysf_frameWidth = 38;
    _satisfaction3.ysf_frameTop = 20;
    _satisfaction3.ysf_frameWidth = 38;
    _satisfaction4.ysf_frameTop = 20;
    _satisfaction4.ysf_frameWidth = 38;
    _satisfaction5.ysf_frameTop = 20;
    _satisfaction5.ysf_frameWidth = 60;
    
    _tagList1.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _tagList1.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _tagList1.ysf_frameTop = 90;
    _tagList1.ysf_frameHeight = 30;
    _tagList2.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _tagList2.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _tagList2.ysf_frameTop = 90;
    _tagList2.ysf_frameHeight = 30;
    _tagList3.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _tagList3.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _tagList3.ysf_frameTop = 90;
    _tagList3.ysf_frameHeight = 30;
    _tagList4.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _tagList4.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _tagList4.ysf_frameTop = 90;
    _tagList4.ysf_frameHeight = 30;
    _tagList5.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _tagList5.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _tagList5.ysf_frameTop = 90;
    _tagList5.ysf_frameHeight = 30;
    
    _evaluationClose.ysf_frameWidth = 40;
    _evaluationClose.ysf_frameHeight = 40;
    _evaluationClose.ysf_frameRight = _imagePanel.ysf_frameWidth;
    _submit.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _submit.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _submit.ysf_frameHeight = 42;
    _submit.ysf_frameTop = CGRectGetHeight(_imagePanel.frame) - 70;
    
    _scrollView.ysf_frameWidth = _imagePanel.ysf_frameWidth;
    _scrollView.ysf_frameTop = _tipLabel.ysf_frameBottom;
    _scrollView.ysf_frameHeight = CGRectGetHeight(_imagePanel.frame) - CGRectGetHeight(_tipLabel.frame) - 90;
    
    NSUInteger evaluationTypeCount = _evaluationDict.count;
    NSUInteger offset = 0;
    if (evaluationTypeCount > 0 ) {
        offset = (_imagePanel.ysf_frameWidth - _satisfaction4.ysf_frameWidth * evaluationTypeCount) / (evaluationTypeCount+1);
    }
    if (evaluationTypeCount == 2) {
        _satisfaction2.hidden = NO;
        _satisfaction4.hidden = NO;
        _satisfaction2.ysf_frameLeft = offset;
        _satisfaction4.ysf_frameLeft = _satisfaction2.ysf_frameRight + offset;
    }
    else if (evaluationTypeCount == 3) {
        _satisfaction2.hidden = NO;
        _satisfaction3.hidden = NO;
        _satisfaction4.hidden = NO;
        _satisfaction2.ysf_frameLeft = offset;
        _satisfaction3.ysf_frameLeft = _satisfaction2.ysf_frameRight + offset;
        _satisfaction4.ysf_frameLeft = _satisfaction3.ysf_frameRight + offset;
    }
    else if (evaluationTypeCount == 5) {
        _satisfaction1.hidden = NO;
        _satisfaction2.hidden = NO;
        _satisfaction3.hidden = NO;
        _satisfaction4.hidden = NO;
        _satisfaction5.hidden = NO;
        _satisfaction1.ysf_frameLeft = offset + 2;
        _satisfaction2.ysf_frameLeft = _satisfaction1.ysf_frameRight + offset - 11;
        _satisfaction3.ysf_frameLeft = _satisfaction2.ysf_frameRight + offset;
        _satisfaction4.ysf_frameLeft = _satisfaction3.ysf_frameRight + offset;
        _satisfaction5.ysf_frameLeft = _satisfaction4.ysf_frameRight + offset - 6;
    }
    
    CGFloat tagButtonRight = 0;
    CGFloat tagButtonBottom = 0;
    CGFloat tagListHeight = 0;
    for (UIButton *tagButton in _tagList1.subviews) {
        [tagButton sizeToFit];
        tagButton.ysf_frameWidth += 20;
        tagButton.ysf_frameLeft = tagButtonRight + 10;
        if (tagButton.ysf_frameRight > _tagList1.ysf_frameWidth) {
            tagButtonBottom = tagButtonBottom + 10 + tagButton.ysf_frameHeight;
            tagButtonRight = 0;
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        else {
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        tagButtonRight = tagButton.ysf_frameRight;
        if (_tagList1 == _selectedTagListView) {
            tagListHeight = tagButton.ysf_frameBottom;
        }
    }
    if (_tagList1 == _selectedTagListView) {
        _tagList1.ysf_frameHeight = tagListHeight;
        tagListHeight = _tagList1.ysf_frameTop + tagListHeight + 20;
    }
    
    tagButtonRight = 0;
    tagButtonBottom = 0;
    for (UIButton *tagButton in _tagList2.subviews) {
        [tagButton sizeToFit];
        tagButton.ysf_frameWidth += 20;
        tagButton.ysf_frameLeft = tagButtonRight + 10;
        if (tagButton.ysf_frameRight > _tagList1.ysf_frameWidth) {
            tagButtonBottom = tagButtonBottom + 10 + tagButton.ysf_frameHeight;
            tagButtonRight = 0;
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        else {
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        tagButtonRight = tagButton.ysf_frameRight;
        if (_tagList2 == _selectedTagListView) {
            tagListHeight = tagButton.ysf_frameBottom;
        }
    }
    if (_tagList2 == _selectedTagListView) {
        _tagList2.ysf_frameHeight = tagListHeight;
        tagListHeight = _tagList2.ysf_frameTop + tagListHeight + 20;
    }
    
    tagButtonRight = 0;
    tagButtonBottom = 0;
    for (UIButton *tagButton in _tagList3.subviews) {
        [tagButton sizeToFit];
        tagButton.ysf_frameWidth += 20;
        tagButton.ysf_frameLeft = tagButtonRight + 10;
        if (tagButton.ysf_frameRight > _tagList1.ysf_frameWidth) {
            tagButtonBottom = tagButtonBottom + 10 + tagButton.ysf_frameHeight;
            tagButtonRight = 0;
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        else {
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        tagButtonRight = tagButton.ysf_frameRight;
        if (_tagList3 == _selectedTagListView) {
            tagListHeight = tagButton.ysf_frameBottom;
        }
    }
    if (_tagList3 == _selectedTagListView) {
        _tagList3.ysf_frameHeight = tagListHeight;
        tagListHeight = _tagList3.ysf_frameTop + tagListHeight + 20;
    }
    
    tagButtonRight = 0;
    tagButtonBottom = 0;
    for (UIButton *tagButton in _tagList4.subviews) {
        [tagButton sizeToFit];
        tagButton.ysf_frameWidth += 20;
        tagButton.ysf_frameLeft = tagButtonRight + 10;
        if (tagButton.ysf_frameRight > _tagList1.ysf_frameWidth) {
            tagButtonBottom = tagButtonBottom + 10 + tagButton.ysf_frameHeight;
            tagButtonRight = 0;
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        else {
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        tagButtonRight = tagButton.ysf_frameRight;
        if (_tagList4 == _selectedTagListView) {
            tagListHeight = tagButton.ysf_frameBottom;
        }
    }
    if (_tagList4 == _selectedTagListView) {
        _tagList4.ysf_frameHeight = tagListHeight;
        tagListHeight = _tagList4.ysf_frameTop + tagListHeight + 20;
    }
    
    tagButtonRight = 0;
    tagButtonBottom = 0;
    for (UIButton *tagButton in _tagList5.subviews) {
        [tagButton sizeToFit];
        tagButton.ysf_frameWidth += 20;
        tagButton.ysf_frameLeft = tagButtonRight + 10;
        if (tagButton.ysf_frameRight > _tagList1.ysf_frameWidth) {
            tagButtonBottom = tagButtonBottom + 10 + tagButton.ysf_frameHeight;
            tagButtonRight = 0;
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        else {
            tagButton.ysf_frameLeft = tagButtonRight + 10;
            tagButton.ysf_frameTop = tagButtonBottom + 10;
        }
        tagButtonRight = tagButton.ysf_frameRight;
        if (_tagList5 == _selectedTagListView) {
            tagListHeight = tagButton.ysf_frameBottom;
        }
    }
    if (_tagList5 == _selectedTagListView) {
        _tagList5.ysf_frameHeight = tagListHeight;
        tagListHeight = _tagList5.ysf_frameTop + tagListHeight + 20;
    }
    
    _textView.ysf_frameWidth = _imagePanel.ysf_frameWidth - 32;
    _textView.ysf_frameCenterX = _imagePanel.ysf_frameCenterX;
    _textView.ysf_frameHeight = 62;
    _textView.ysf_frameTop = 110;
    if (tagListHeight != 0) {
        _textView.ysf_frameTop = tagListHeight;
        _scrollView.contentSize = CGSizeMake(_imagePanel.ysf_frameWidth, _textView.ysf_frameBottom);
    }
}

- (void)updateLastResult {
    if (self.lastResult) {
        if ([self.lastResult.title isEqualToString:@"非常满意"]) {
            [self onSelect:_satisfaction1 selectedTagListView:_tagList1];
            for (NSString *selectTagString in self.lastResult.tagList) {
                for (UIButton *tagButton in _tagList1.subviews) {
                    if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                        tagButton.selected = YES;
                        tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    }
                }
            }
        } else if ([self.lastResult.title isEqualToString:@"满意"]) {
            [self onSelect:_satisfaction2 selectedTagListView:_tagList2];
            for (NSString *selectTagString in self.lastResult.tagList) {
                for (UIButton *tagButton in _tagList2.subviews) {
                    if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                        tagButton.selected = YES;
                        tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    }
                }
            }
        } else if ([self.lastResult.title isEqualToString:@"一般"]) {
            [self onSelect:_satisfaction3 selectedTagListView:_tagList3];
            for (NSString *selectTagString in self.lastResult.tagList) {
                for (UIButton *tagButton in _tagList3.subviews) {
                    if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                        tagButton.selected = YES;
                        tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    }
                }
            }
        } else if ([self.lastResult.title isEqualToString:@"不满意"]) {
            [self onSelect:_satisfaction4 selectedTagListView:_tagList4];
            for (NSString *selectTagString in self.lastResult.tagList) {
                for (UIButton *tagButton in _tagList4.subviews) {
                    if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                        tagButton.selected = YES;
                        tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    }
                }
            }
        } else if ([self.lastResult.title isEqualToString:@"非常不满意"]) {
            [self onSelect:_satisfaction5 selectedTagListView:_tagList5];
            for (NSString *selectTagString in self.lastResult.tagList) {
                for (UIButton *tagButton in _tagList5.subviews) {
                    if ([[tagButton titleForState:UIControlStateNormal] isEqualToString:selectTagString]) {
                        tagButton.selected = YES;
                        tagButton.backgroundColor = YSFColorFromRGB(0x999999);
                    }
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

- (void)onClose:(id)sender
{
    if (_submit.enabled) {
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
        [self closeHandle];
    }
    [self.textView resignFirstResponder];   //否则close评价窗口键盘会抖动
}

- (void)closeHandle
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        weakSelf.evaluationCallback(NO, nil);
    }];
}

- (void)onSelect:(id)sender selectedTagListView:(UIView *)selectedTagListView
{
    [self.view endEditing:YES];
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];

    _selectedTagListView.hidden = YES;
    _selectedTagListView = selectedTagListView;
    _selectedTagListView.hidden = NO;
    _selectedButton.selected = NO;
    _selectedButton.titleLabel.backgroundColor = [UIColor clearColor];
    [_imagePanel bringSubviewToFront:selectedTagListView];
    UIButton *button = sender;
    button.selected = true;
    
    _selectedButton = button;
    _selectedButton.titleLabel.backgroundColor = YSFColorFromRGB(0x999999);
    
    CGAffineTransform oldTransForm =  button.imageView.transform;
    CGAffineTransform transform = CGAffineTransformScale(oldTransForm, 1.2, 1.2);
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        button.imageView.transform = transform;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^{
            button.imageView.transform = oldTransForm;
        } completion:nil];
    }];
    
    [self.view setNeedsLayout];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_scrollView ysf_scrollToBottom:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        _placeholderLabel.hidden = YES;
    }
    else{
        _placeholderLabel.hidden = NO;
    }
    
    NSString *nsTextContent = textView.text;
    if (nsTextContent.length > 100)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:100];
        [textView setText:s];
    }
    
    //解决自动上下移动问题
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height- ( textView.contentOffset.y + textView.bounds.size.height- textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
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

- (void)onSubmit:(id)sender {
    [self updateSubmitButtonEnable:YSFEvaluationSubmitTypeSubmitting];
    NSString *selectString = _selectedButton.titleLabel.text;
    NSDictionary *dict = [_evaluationDict objectForKey:selectString];
    NSUInteger selectScore = 0;
    //比较老的版本，存在本地的数据，dict是一个Number，所以这里需要判断一下
    if ([dict isKindOfClass:[NSNumber class]]) {
        selectScore = [(NSNumber *)dict unsignedIntegerValue];
    } else {
        selectScore = [dict ysf_jsonUInteger:YSFApiKeyValue];
    }
    NSMutableArray *tagList = [NSMutableArray new];
    for (UIButton *tagButton in _selectedTagListView.subviews) {
        if (tagButton.selected) {
            NSString *selectedTagText = tagButton.titleLabel.text;
            [tagList addObject:selectedTagText];
        }
    }
    
    YSFEvaluationRequest *request = [[YSFEvaluationRequest alloc] init];
    request.score = selectScore;
    request.remarks = _textView.text;
    request.sessionId = _sessionId;
    request.tagInfos = tagList;
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {
        if (error) {
            [weakSelf updateSubmitButtonEnable:YSFEvaluationSubmitTypeEnable];
            [weakSelf showToast:@"网络连接失败，请稍后再试"];
        }
    }];
}

- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YSFKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        CGRect imagePanleframe = self.imagePanel.frame;
        imagePanleframe.size.width = kbFrame.size.width;
        imagePanleframe.origin.y = kbFrame.origin.y - imagePanleframe.size.height;
        if (imagePanleframe.origin.y < YSFStatusBarHeight) {
            imagePanleframe.origin.y = YSFStatusBarHeight;
            imagePanleframe.size.height = CGRectGetHeight([UIScreen mainScreen].bounds) - YSFStatusBarHeight - kbFrame.size.height;
        }
        self.imagePanel.frame = imagePanleframe;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.textView becomeFirstResponder];
    }else if (buttonIndex == 1) {
        [self closeHandle];
    }
}

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
                NSString *selectString = _selectedButton.titleLabel.text;
                NSMutableArray *tagList = [NSMutableArray new];
                for (UIButton *tagButton in _selectedTagListView.subviews) {
                    if (tagButton.selected) {
                        NSString *selectedTagText = tagButton.titleLabel.text;
                        [tagList addObject:selectedTagText];
                    }
                }
                YSFEvaluationCommitData *commitData = [[YSFEvaluationCommitData alloc] init];
                commitData.title = selectString;
                commitData.tagList = tagList;
                commitData.content = _textView.text;
                NSMutableDictionary *sessionDict = [[[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:_sessionId] mutableCopy];
                if (sessionDict) {
                    [sessionDict setValue:[commitData toDict] forKey:YSFEvaluationResultData];
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

- (void)updateSubmitButtonEnable:(YSFEvaluationSubmitType)type {
    if (type == YSFEvaluationSubmitTypeEnable) {
        _submit.enabled = YES;
        [_submit setTitle:@"提 交" forState:UIControlStateNormal];
        _submit.backgroundColor = YSFColorFromRGBA(0x5e94e2, 1);
    } else if (type == YSFEvaluationSubmitTypeUnable) {
        _submit.enabled = NO;
        [_submit setTitle:@"提 交" forState:UIControlStateNormal];
        _submit.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFEvaluationSubmitTypeSubmitting) {
        _submit.enabled = NO;
        [_submit setTitle:@"提交中..." forState:UIControlStateNormal];
        _submit.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    }
}

- (void)showToast:(NSString *)toast {
    if (toast.length) {
        UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
        [topWindow ysf_makeToast:toast duration:2 position:YSFToastPositionCenter];
    }
}

@end

//
//  YSFMessageFormViewController.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormViewController.h"
#import "YSFReachability.h"
#import "YSFTools.h"
#import "YSFTimer.h"
#import "NSArray+YSF.h"
#import "UIView+YSFToast.h"
#import "YSFKeyboardManager.h"
#import "YSFLoadingView.h"
#import "YSFMessageFormField.h"
#import "YSFMenuModel.h"
#import "YSFMessageFormRequest.h"
#import "YSFMessageFormFieldView.h"
#import "YSFMenuViewController.h"
#import "YSFMessageFormResult.h"
#import "YSFMessageFormResponse.h"
#import "YSFCustomSystemNotificationParser.h"


static CGFloat YSFMessageFormTopSpace = 16.0f;
static CGFloat YSFMessageFormHorizontalSpace = 16.0f;
static CGFloat YSFMessageFormSendButtonHeight = 48.0f;
static CGFloat YSFMessageFormSendButtonVerticalSpace = 15.0f;


typedef NS_ENUM(NSInteger, YSFMessageFormSendType) {
    YSFMessageFormSendTypeEnable = 0,  //提交，可点击
    YSFMessageFormSendTypeUnable,      //提交，不可点击
    YSFMessageFormSendTypeHighlighted, //提交，高亮状态
    YSFMessageFormSendTypeSending,     //提交中，不可点击
};


@interface YSFMessageFormViewController () <YSFKeyboardObserver, YSFLoadingViewDelegate, YSFMessageFormFieldViewDelegate, YSF_NIMSystemNotificationManagerDelegate>

@property (nonatomic, copy) NSString *shopId;
@property (nonatomic, copy) NSString *tip;
@property (nonatomic, strong) NSMutableArray *formData;

@property (nonatomic, strong) YSFLoadingView *loadingView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *fieldViews;
@property (nonatomic, strong) UIView *attachmentView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) YSFTimer *waitTimer;

@property (nonatomic, strong) UIImageView *successView;
@property (nonatomic, strong) UILabel *successLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end


@implementation YSFMessageFormViewController
- (void)dealloc {
    [[YSFKeyboardManager defaultManager] removeObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (instancetype)initWithShopId:(NSString *)shopId tip:(NSString *)tip {
    self = [super init];
    if (self) {
        _shopId = shopId ? shopId : @"-1";
        _tip = tip;
        
        _waitTimer = [[YSFTimer alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"填写留言";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadMessageFormData];
    
    [[YSFKeyboardManager defaultManager] addObserver:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
}

#pragma mark - Load Data
- (void)loadMessageFormData {
    if (![[YSFReachability reachabilityForInternetConnection] isReachable]) {
        [self showloadingView:YSFLoadingTypeFail];
        return;
    }
    [self showloadingView:YSFLoadingTypeLoading];
    __weak typeof(self) weakSelf = self;
    YSFMessageFormRequest *request = [[YSFMessageFormRequest alloc] init];
    request.shopId = _shopId;
    [YSFHttpApi get:request completion:^(NSError *error, id returendObject) {
        if (!error && returendObject && [returendObject isKindOfClass:[NSArray class]]) {
            weakSelf.formData = [NSMutableArray arrayWithArray:returendObject];
            BOOL attachment = NO;
            YSFMessageFormField *lastField = [weakSelf.formData lastObject];
            if (lastField && lastField.type == YSFMessageFormFieldTypeAttachment) {
                [weakSelf.formData removeLastObject];
                attachment = YES;
            }
            YSFMessageFormField *msgField = [YSFMessageFormField makeFieldWithType:YSFMessageFormFieldTypeMessage];
            msgField.required = YES;
            [weakSelf.formData addObject:msgField];
            if ([weakSelf.formData count] > 0) {
                [weakSelf removeLoadingView];
                [weakSelf reloadViewWithAttachment:attachment];
            } else {
                [weakSelf showloadingView:YSFLoadingTypeNoData];
            }
        } else {
            [weakSelf showloadingView:YSFLoadingTypeFail];
        }
    }];
}

#pragma mark - Init View
- (void)reloadViewWithAttachment:(BOOL)attachment {
    [self.view ysf_removeAllSubviews];
    //scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.backgroundColor = YSFColorFromRGB(0xf5f6f7);
    if (@available(iOS 11, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_scrollView];
    //seperatorLine
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
    [self.view addSubview:_seperatorLine];
    //sendButton
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _sendButton.layer.cornerRadius = 3.0;
    [_sendButton addTarget:self action:@selector(onSendTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_sendButton addTarget:self action:@selector(onSendTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton addTarget:self action:@selector(onSendTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:_sendButton];
    [self updateSendButtonEnable:YSFMessageFormSendTypeEnable];
    //titleLabel
    if (_tip.length) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _titleLabel.textColor = YSFColorFromRGB(0x999999);
        _titleLabel.text = _tip;
        [_scrollView addSubview:_titleLabel];
    }
    //fieldViews
    self.fieldViews = [NSMutableArray arrayWithCapacity:[self.formData count]];
    for (YSFMessageFormField *fieldData in self.formData) {
        YSFMessageFormFieldView *fieldView = [[YSFMessageFormFieldView alloc] init];
        fieldView.fieldData = fieldData;
        fieldView.delegate = self;
        [_scrollView addSubview:fieldView];
        [self.fieldViews addObject:fieldView];
    }
    //attachment
    if (attachment) {
        _attachmentView = [[UIView alloc] initWithFrame:CGRectZero];
        _attachmentView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.2];
        [_scrollView addSubview:_attachmentView];
    }
    [self refreshFrame];
}

- (void)showloadingView:(YSFLoadingType)type {
    if (!_loadingView) {
        _loadingView = [[YSFLoadingView alloc] initWithFrame:CGRectZero];
        _loadingView.delegate = self;
        [self.view addSubview:_loadingView];
    }
    _loadingView.hidden = NO;
    _loadingView.type = type;
    [self.view bringSubviewToFront:_loadingView];
}

- (void)removeLoadingView {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)updateSendButtonEnable:(YSFMessageFormSendType)type {
    if (type == YSFMessageFormSendTypeEnable) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = YES;
        [_sendButton setTitle:@"发 送" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 1);
    } else if (type == YSFMessageFormSendTypeUnable) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"发 送" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFMessageFormSendTypeHighlighted) {
        self.view.userInteractionEnabled = YES;
        _sendButton.enabled = YES;
        [_sendButton setTitle:@"发 送" forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    } else if (type == YSFMessageFormSendTypeSending) {
        self.view.userInteractionEnabled = NO;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"发送中..." forState:UIControlStateNormal];
        _sendButton.backgroundColor = YSFColorFromRGBA(0x5e94e2, 0.6);
    }
}

- (void)showSuccessView {
    [self.view ysf_removeAllSubviews];
    self.navigationItem.rightBarButtonItem = nil;
    
    UIImage *image = [UIImage ysf_imageInKit:@"icon_msg_success"];
    self.successView = [[UIImageView alloc] initWithImage:image];
    self.successView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    CGFloat offset = CGRectGetHeight(self.view.bounds) / 3 - 10;
    self.successView.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, offset + CGRectGetHeight(self.successView.bounds) / 2);
    [self.view addSubview:self.successView];
    
    self.successLabel = [[UILabel alloc] init];
    self.successLabel.font = [UIFont systemFontOfSize:16];
    self.successLabel.textColor = YSFColorFromRGB(0x666666);
    self.successLabel.textAlignment = NSTextAlignmentCenter;
    self.successLabel.text = @"留言成功";
    self.successLabel.frame = CGRectMake(0, CGRectGetMaxY(self.successView.frame) + 12, CGRectGetWidth(self.view.bounds), 20);
    [self.view addSubview:self.successLabel];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.backgroundColor = [UIColor clearColor];
    self.closeButton.layer.cornerRadius = 5.0f;
    self.closeButton.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    self.closeButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    [self.closeButton addTarget:self action:@selector(onTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.frame = CGRectMake(ROUND_SCALE((CGRectGetWidth(self.view.bounds) - 130) / 2), CGRectGetMaxY(self.successLabel.frame) + 40, 130, 48);
    [self.view addSubview:self.closeButton];
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _loadingView.frame = self.view.bounds;
}

- (void)refreshFrame {
    CGFloat offsetY = 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds) - YSFNavigationBarHeight;
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = self.view.safeAreaInsets.bottom;
    }
    _scrollView.frame = CGRectMake(0,
                                   YSFNavigationBarHeight,
                                   width,
                                   height - 2 * YSFMessageFormSendButtonVerticalSpace - YSFMessageFormSendButtonHeight - bottom);
    _seperatorLine.frame = CGRectMake(0, CGRectGetMaxY(_scrollView.frame), width, lineHeight);
    _sendButton.frame = CGRectMake(YSFMessageFormHorizontalSpace,
                                   CGRectGetMaxY(_scrollView.frame) + YSFMessageFormSendButtonVerticalSpace,
                                   width - 2 * YSFMessageFormHorizontalSpace,
                                   YSFMessageFormSendButtonHeight);
    offsetY = YSFMessageFormTopSpace;
    if (_tip.length) {
        NSDictionary *dict = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};
        CGSize size = [_tip boundingRectWithSize:CGSizeMake(width - 2 * YSFMessageFormHorizontalSpace, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:dict
                                         context:nil].size;
        _titleLabel.frame = CGRectMake(YSFMessageFormHorizontalSpace,
                                       YSFMessageFormTopSpace,
                                       width - 2 * YSFMessageFormHorizontalSpace,
                                       ROUND_SCALE(size.height + 1));
        offsetY = CGRectGetMaxY(_titleLabel.frame) + YSFMessageFormFieldVerticalSpace;
    }
    
    for (YSFMessageFormFieldView *fieldView in self.fieldViews) {
        CGFloat fieldHeight = 0;
        if (fieldView.fieldData.type == YSFMessageFormFieldTypeMessage) {
            fieldHeight = YSFMessageFormFieldHeight_Message + 2 * YSFMessageFormFieldVerticalSpace;
        } else {
            fieldHeight = YSFMessageFormFieldHeight + 2 * YSFMessageFormFieldVerticalSpace;
        }
        fieldView.frame = CGRectMake(0, offsetY, width, fieldHeight);
        offsetY = CGRectGetMaxY(fieldView.frame);
    }
    offsetY += YSFMessageFormTopSpace;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), offsetY);
}

#pragma mark - Action
- (void)onSendTouchDown:(id)sender {
    [self updateSendButtonEnable:YSFMessageFormSendTypeHighlighted];
}

- (void)onSendTouchUpInside:(id)sender {
    UIImage *image = [UIImage ysf_imageInKit:@"icon_fail"];
    //发送留言结果
    YSFMessageFormResult *result = [[YSFMessageFormResult alloc] init];
    result.shopId = self.shopId;
    NSMutableArray *array = [NSMutableArray array];
    BOOL isAllRequired = YES;
    for (YSFMessageFormField *field in self.formData) {
        if (field.required) {
            if (!field.value
                || field.value.length == 0
                || [field.value isEqualToString:@"未选择"]) {
                isAllRequired = NO;
                break;
            }
        }
        if (field.type == YSFMessageFormFieldTypeMessage) {
            result.message = field.value;
        } else if (field.type == YSFMessageFormFieldTypePhone) {
            result.mobile = field.value;
        } else if (field.type == YSFMessageFormFieldTypeEmail) {
            result.email = field.value;
        } else {
            if (![field.value isEqualToString:@"未选择"]) {
                NSDictionary *dict = [field getResultDict];
                if (dict && [dict count]) {
                    [array addObject:dict];
                }
            }
        }
    }
    if (!isAllRequired) {
        [self updateSendButtonEnable:YSFMessageFormSendTypeEnable];
        [self.view ysf_makeToast:@"必填项未填" image:image shadow:NO duration:2.0f];
        return;
    }
    if (array.count) {
        result.customFields = [array ysf_toUTF8String];
    }
    
    [self updateSendButtonEnable:YSFMessageFormSendTypeSending];
    [self.view ysf_makeActivityToast:@"发送中" shadow:NO];
    __weak typeof(self) weakSelf = self;
    [_waitTimer start:dispatch_get_main_queue() interval:10 repeats:NO block:^{
        [weakSelf updateSendButtonEnable:YSFMessageFormSendTypeEnable];
        [weakSelf.view ysf_makeToast:@"发送超时" image:image shadow:NO duration:2.0f];
    }];
    
    [YSFIMCustomSystemMessageApi sendMessage:result completion:^(NSError *error) {
        if (error) {
            [weakSelf.waitTimer stop];
            [weakSelf updateSendButtonEnable:YSFMessageFormSendTypeEnable];
            [weakSelf.view ysf_makeToast:@"发送失败" image:image shadow:NO duration:2.0f];
        }
    }];
}

- (void)onSendTouchUpOutside:(id)sender {
    [self updateSendButtonEnable:YSFMessageFormSendTypeEnable];
}

- (void)onTouchCloseButton:(id)sender {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (YSFMessageFormField *field in self.formData) {
        if (field.value.length
            && ![field.value isEqualToString:@"未选择"]) {
            if (field.type == YSFMessageFormFieldTypeMessage) {
                [resultArray addObject:@{@"留言" : YSFStrParam(field.value)}];
            } else {
                [resultArray addObject:@{YSFStrParam(field.name) : YSFStrParam(field.value)}];
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseMessageFormWithTitle:resultData:)]) {
        [self.delegate onCloseMessageFormWithTitle:@"我的留言表单" resultData:resultArray];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YSFKeyboardObserver
- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        [self.view setNeedsLayout];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - YSFLoadingViewDelegate
- (void)tapRefreshButton:(id)sender {
    [self loadMessageFormData];
}

#pragma mark - YSFMessageFormFieldViewDelegate
- (void)onTapMessageFormFieldView:(YSFMessageFormFieldView *)fieldView {
    [self.view endEditing:YES];
    if (fieldView.fieldData.type == YSFMessageFormFieldTypeSingleMenu
        || fieldView.fieldData.type == YSFMessageFormFieldTypeMultipleMenu) {
        if ([fieldView.options count]) {
            __weak typeof(fieldView) weakView = fieldView;
            YSFMenuViewController *menuVC = [[YSFMenuViewController alloc] initWithFieldType:fieldView.fieldData.type
                                                                                       title:fieldView.fieldData.name
                                                                                 optionArray:fieldView.options
                                                                                  completion:^{
                                                                                      [weakView reload];
                                                                                  }];
            [self.navigationController pushViewController:menuVC animated:YES];
        }
    }
}

#pragma mark - YSF_NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification {
    NSString *content = notification.content;
    //平台电商时sender等于shopId (目前服务器如此处理)
    NSString *shopId = notification.sender;
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    //解析
    id object =  [YSFCustomSystemNotificationParser parse:content shopId:shopId];
    
    if ([object isKindOfClass:[YSFMessageFormResponse class]]) {
        YSFMessageFormResponse *result = (YSFMessageFormResponse *)object;
        [self.waitTimer stop];
        [self.view ysf_hideToastActivity];
        [self updateSendButtonEnable:YSFMessageFormSendTypeEnable];
        if (result.auditResult == 1) {
            UIImage *image = [UIImage ysf_imageInKit:@"icon_fail"];
            [self.view ysf_makeToast:@"留言失败" image:image shadow:NO duration:2.0f];
        } else {
            [self showSuccessView];
        }
    }
}

@end

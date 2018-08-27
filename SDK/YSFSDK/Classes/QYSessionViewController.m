//
//  YSFSessionViewController.m
//  YSFSDK
//
//  Created by amao on 8/25/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "QYSessionViewController_Private.h"

#import "YSFApiDefines.h"
#import "NIMTipObject.h"
#import "YSFReachability.h"
#import "YSFInputToolBar.h"
#import "YSFKitEvent.h"
#import "YSFGalleryViewController.h"
#import "YSFImageConfirmedViewController.h"
#import "YSFWebViewController.h"
#import "QYCustomUIConfig+Private.h"
#import "QYPOPSDK.h"
#import "YSFEvaluationViewController.h"
#import "YSFEvaluationRequest.h"
#import "YSFMachineResponse.h"
#import "YSFReportQuestion.h"
#import "NSAttributedString+YSFHTML.h"
#import "YSFEvaluationTipObject.h"
#import "NSString+Regex.h"
#import "YSFAlertController.h"
#import "YSFKFBypassNotification.h"
#import "YSFSetCommodityInfoRequest.h"
#import "QYCommodityInfo.h"
#import "QYCommodityInfo.h"
#import "YSFStartServiceObject.h"
#import "YSFInviteEvaluationObject.h"
#import "QYCustomActionConfig+Private.h"
#import "YSFTransAudioToTextLoadingViewController.h"
#import "KFAudioToTextHandler.h"
#import "YSFQueryWaitingStatus.h"
#import "YSFTimer.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFFilePreviewViewController.h"
#import "YSFOrderList.h"
#import "YSFSelectedGoods.h"
#import "YSFOrderOperation.h"
#import "YSFMoreOrderListViewController.h"
#import "YSFCancelWaitingRequest.h"
#import "YSFNotification.h"
#import "YSFPopTipView.h"
#import "YSFEvaluationAnswerRequest.h"
#import "YSFRichText.h"
#import "YSFSessionMessageContentView.h"
#import "YSFRichTextContentView.h"
#import "YSFSessionMachineContentView.h"
#import "YSFBotForm.h"
#import "YSFBotFormViewController.h"
#import "YSFStaticUnion.h"
#import "YSFStaticUnionContentView.h"
#import "YSFSubmittedBotForm.h"
#import "YSFSubmittedBotFormContentView.h"
#import "YSFSystemConfig.h"
#import "YSFSendInputtingMessageRequest.h"
#import "YSFSetEvaluationReasonRequest.h"
#import "YSFBypassViewController.h"
#import "YSFSendSearchQuestionRequest.h"
#import "YSFSendSearchQuestionResponse.h"
#import "KFQuickReplyContentView.h"
#import "YSFSearchQuestionSetting.h"
#import "KFNewMsgTipViewToDown.h"
#import "YSFSearchQuestionSetting.h"
#import "YSFBotCustomObject.h"
#import "YSFBotEntry.h"
#import "QYCommodityInfo_private.h"

@import MobileCoreServices;
@import AVFoundation;

typedef enum : NSUInteger {
    YSFImagePickerModePicture,
    YSFImagePickerModeShoot,
} YSFImagePickerMode;

YSFInputStatus g_inputStatus = YSFInputStatusText;
QYCommodityInfo *g_commodityInfo = nil;
int64_t g_commonQuestionTemplateId = 0;
static long long g_sessionId;


@implementation YSFKaolaTagInfo
@end

@implementation QYButtonInfo
@end

@interface QYSessionViewController()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, YSF_NIMSystemNotificationManagerDelegate, YSFAppInfoManagerDelegate, YSFEvaluationReasonViewDelegate, YSFQuickReplyContentViewDelegate>
@property (nonatomic,assign)    YSFImagePickerMode      mode;
@property (nonatomic,strong)    UIButton *humanService;
@property (nonatomic,strong)    UIButton *humanServiceText;
@property (nonatomic,strong)    UIButton *shopEntrance;
@property (nonatomic,strong)    UIButton *shopEntranceText;
@property (nonatomic,strong)    UIButton *evaluation;
@property (nonatomic,strong)    UIButton *evaluationText;
@property (nonatomic,strong)    UIButton *closeSession;
@property (nonatomic,strong)    UIButton *closeSessionText;
@property (nonatomic,strong)    UIButton *moreButton;
@property (nonatomic,strong)    UIButton *moreButtonText;
@property (nonatomic,strong)    UIImageView *sessionListImageView;
@property (nonatomic,strong)    UIButton *sessionListButton;
@property (nonatomic,copy)      NSString* emailStr;
@property (nonatomic,assign)    int64_t entryId;
@property (nonatomic,assign)    BOOL specifiedId;
@property (nonatomic,strong)    YSF_NIMMessage *currentInviteEvaluationMessage;
@property (nonatomic,assign)    BOOL hasRequested;
@property (nonatomic,strong)    YSFTimer *queryWaitingStatusTimer;
@property (nonatomic,copy)      NSString *shopId;                       //平台电商店铺Id，不是平台电商不用管
@property (nonatomic,weak)      id<QYSessionViewDelegate> delegate;     //会话窗口回调
@property (nonatomic,strong)    YSFPopTipView *popTipView;
@property (nonatomic,strong)    YSFTimer *inputtingMessage;
@property (nonatomic,copy)      NSString *lastMessageContent;
@property (nonatomic,strong)    NSMutableArray<YSFActionInfo *> *ysfActionInfoArray;
@property (nonatomic, strong)   YSFQuickReplyContentView *quickReplyView;

@end


@implementation QYSessionViewController

- (void)setShopId:(NSString *)shopId
{
    _shopId = [shopId lowercaseString];
}

- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if ([[QYSDK sharedSDK] infoManager].accountInfo.bid) {
            _shopId = [[QYSDK sharedSDK] infoManager].accountInfo.bid;
        }
        _reachability = [YSFReachability reachabilityForInternetConnection];
        _specifiedId = NO;
        _hasRequested = NO;
        _openRobotInShuntMode = NO;
        _queryWaitingStatusTimer = [[YSFTimer alloc]init];
        _inputtingMessage = [[YSFTimer alloc]init];
    }
    return self;
}

//初始化会话session
- (void)initSession
{
    YSF_NIMSession *session  = [YSF_NIMSession session:_shopId type:YSF_NIMSessionTypeYSF];
    _session = session;
}

- (void)viewDidLoad {
    if (_groupId || _staffId) {
        self.specifiedId = YES;
    }

    [super viewDidLoad];
    [self initSession];
    [self makeUI];
    [self makeHandlerAndDataSource];
    
    extern NSString *kKFInputViewInputTypeChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputViewInputTypeChanged:) name:kKFInputViewInputTypeChanged object:nil];

    __weak typeof(self) weakSelf = self;
    [QYCustomActionConfig sharedInstance].showQuitBlock = ^(QYQuitWaitingBlock showQuitWaitingBlock) {
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        if ([sessionManager getSessionStateType:weakSelf.shopId] != YSFSessionStateTypeWaiting) {
            if (showQuitWaitingBlock) {
                showQuitWaitingBlock(QuitWaitingTypeNone);
            }
            return;
        }
        
        YSFAlertController * alertController = [YSFAlertController alertWithTitle:@"" message:@"是否继续咨询在线客服？您可以先去逛逛，排队成功后将提醒您"];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"帮我排队" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (showQuitWaitingBlock) {
                showQuitWaitingBlock(QuitWaitingTypeContinue);
            }
        }]];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"下次咨询" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf sendCloseSessionCustomMessage:YES quitSessionViewController:YES
                               showQuitWaitingBlock:showQuitWaitingBlock];
        }]];
        [alertController addCancelActionWithHandler:^(YSFAlertAction * _Nonnull action) {
            if (showQuitWaitingBlock) {
                showQuitWaitingBlock(QuitWaitingTypeCancel);
            }
        }];
        
        [alertController showWithSender:nil arrowDirection:UIPopoverArrowDirectionAny controller:weakSelf animated:YES completion:nil];
    };
    
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    BOOL shouldRequestService = YES;
    id model = [[_sessionDatasource modelArray] lastObject];
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        YSF_NIMMessage *message = ((YSFMessageModel *)model).message;
        if (message.messageType == YSF_NIMMessageTypeCustom) {
            id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(message.messageObject) attachment];
            if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]]) {
                _currentInviteEvaluationMessage = message;
            }
        }
    }
    
    if ((_staffId != 0 && [sessionManager getOnlineSession:_shopId].realStaffId != _staffId)
        || (_groupId != 0 && [sessionManager getOnlineSession:_shopId].groupId != _groupId)
        || (_robotId != 0 && [sessionManager getOnlineSession:_shopId].realStaffId != -_robotId)
        || (_commonQuestionTemplateId != g_commonQuestionTemplateId)) {
        shouldRequestService = YES;
        [sessionManager clearByShopId:_shopId];
    }
    g_commonQuestionTemplateId = _commonQuestionTemplateId;
    NSInteger count = [[[YSF_NIMSDK sharedSDK] conversationManager] unreadCountInSession:_session];
    if (count > 0) {
        shouldRequestService = NO;
        NSDictionary *dict = [sessionManager getEvaluationInfoByShopId:_shopId];
        NSInteger status = [[dict objectForKey:YSFSessionStatus] integerValue];
        if (status == 2) {
            if (_changeEvaluationEnabledBlock) {
                _changeEvaluationEnabledBlock(YES);
            }
            if ([QYCustomUIConfig sharedInstance].showEvaluationEntry) {
                _evaluation.hidden = NO;
                _evaluation.enabled = YES;
                _evaluationText.hidden = NO;
                _evaluationText.enabled = YES;
            }
        }
    }
    
    if ([sessionManager getOnlineSession:_shopId] && [sessionManager getOnlineSession:_shopId].humanOrMachine)
    {
        if (_commodityInfo && (![g_commodityInfo isEqual:_commodityInfo] || _commodityInfo.sendByUser)) {
            [self sendCommodityInfoRequest:YES];
        }
    }
    
    if (shouldRequestService) {
        [self requestServiceIfNeeded:YES onlyManual:NO];
    }
    
    [[[YSF_NIMSDK sharedSDK] conversationManager] markAllMessageReadInSession:_session];
    [sessionManager reportPushMessageReadedStatus];
    
    NSString *text = [[[QYSDK sharedSDK] infoManager] cachedText:_shopId];
    [self.sessionInputView setInputText:text];
    BOOL autoPopUp = [self showEvaluaViewController];
    if (!autoPopUp && [QYCustomUIConfig sharedInstance].autoShowKeyboard && g_inputStatus != YSFInputStatusAudio) {
        [self.sessionInputView.toolBar.inputTextView becomeFirstResponder];
    }
}

- (void)inputViewInputTypeChanged:(NSNotification*)sender {
    NSNumber *type = (NSNumber*)sender.object;
    YSFInputStatus inputType = (YSFInputStatus)type.integerValue;
    if (inputType == YSFInputStatusAudio) {
        if (_quickReplyView) {
            _quickReplyView.hidden = YES;
        }
    } else if (inputType == YSFInputStatusText || inputType == YSFInputStatusEmoticon) {
        if (_quickReplyView) {
            _quickReplyView.hidden = NO;
        }
    }
}

- (void)sendCloseSessionCustomMessage:(BOOL)quitWaitingOrCloseSession quitSessionViewController:(BOOL)quitSessionViewController
        showQuitWaitingBlock:(QYQuitWaitingBlock)showQuitWaitingBlock
{
    UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
    if (quitWaitingOrCloseSession) {
        [topmostWindow ysf_makeToast:@"退出排队中" duration:2 position:YSFToastPositionCenter];
    }
    else {
        [topmostWindow ysf_makeToast:@"退出对话中" duration:2 position:YSFToastPositionCenter];
    }
    
    __weak typeof(self) weakSelf = self;
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    YSFCancelWaitingRequest *request = [YSFCancelWaitingRequest new];
    request.sessionId = [sessionManager getOnlineOrWaitingSession:_shopId].sessionId;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error){
        if (error) {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            if (quitWaitingOrCloseSession) {
                [topmostWindow ysf_makeToast:@"退出排队失败，请稍后再试" duration:2 position:YSFToastPositionCenter];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            else {
                [topmostWindow ysf_makeToast:@"退出对话失败，请稍后再试" duration:2 position:YSFToastPositionCenter];
            }
        }
        else {
            YSFNotification *notification = [[YSFNotification alloc] init];
            notification.command = YSFCommandNotification;
            notification.localCommand = YSFCommandSessionWillClose;
            notification.message = @"您退出了咨询";
            YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
            YSF_NIMSession *session = [YSF_NIMSession session:weakSelf.shopId type:YSF_NIMSessionTypeYSF];
            [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
            
            if (quitWaitingOrCloseSession) {
                if (quitSessionViewController) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            
            if (showQuitWaitingBlock) {
                showQuitWaitingBlock(QuitWaitingTypeQuit);
            }
        }
    }];
}


- (void)sendCloseSessionCustomMessage:(BOOL)quitWaitingOrCloseSession
                 completetionBlock:(void (^)(BOOL isSuccess))completetionBlock
{
    UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
    if (quitWaitingOrCloseSession) {
        [topmostWindow ysf_makeToast:@"退出排队中" duration:2 position:YSFToastPositionCenter];
    }
    else {
        [topmostWindow ysf_makeToast:@"退出对话中" duration:2 position:YSFToastPositionCenter];
    }
    
    __weak typeof(self) weakSelf = self;
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    YSFCancelWaitingRequest *request = [YSFCancelWaitingRequest new];
    request.sessionId = [sessionManager getOnlineOrWaitingSession:_shopId].sessionId;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error){
        if (error) {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            if (quitWaitingOrCloseSession) {
                [topmostWindow ysf_makeToast:@"退出排队失败，请稍后再试" duration:2 position:YSFToastPositionCenter];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
            else {
                [topmostWindow ysf_makeToast:@"退出对话失败，请稍后再试" duration:2 position:YSFToastPositionCenter];
            }
        }
        else {
            if (!quitWaitingOrCloseSession) {
                YSFNotification *notification = [[YSFNotification alloc] init];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandSessionWillClose;
                notification.message = @"您退出了咨询";
                YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
                YSF_NIMSession *session = [YSF_NIMSession session:weakSelf.shopId type:YSF_NIMSessionTypeYSF];
                [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
            }
        }
        
        if (completetionBlock) {
            completetionBlock(error == nil);
        }
        
    }];
}

- (void)menuDidHide:(NSNotification *)notification
{
    self.sessionInputView.toolBar.inputTextView.overrideNextResponder = nil;
    [UIMenuController sharedMenuController].menuItems = nil;
}

-(void)dealloc
{
    YSFLogApp(@"");

    [_reachability stopNotifier];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YSF_NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[YSF_NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[YSF_NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    g_inputStatus = _sessionInputView.inputStatus;
}

- (void)viewWillDisappear:(BOOL)animated
{
    YSFLogApp(@"");

    [super viewWillDisappear:animated];
    [[YSF_NIMSDK sharedSDK].mediaManager cancelRecord];
    [[YSF_NIMSDK sharedSDK].mediaManager stopPlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    YSFLogApp(@"");

    [super viewDidAppear:animated];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
        [self.view setNeedsLayout];
    }
}

- (void)makeUI
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[QYSDK sharedSDK].infoManager initSessionViewControllerInfo];
    });

    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    self.navigationItem.title = [self sessionTitle];
    
    //两个按钮的父类view
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
    
    //人工客服
    _humanService = [[UIButton alloc] init];
    [_humanService addTarget:self action:@selector(onHumanChat:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_humanService];
    _humanServiceText = [[UIButton alloc] init];
    [rightButtonView addSubview:_humanServiceText];
    [_humanServiceText setTitle:@"人工" forState:UIControlStateNormal];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        [_humanServiceText setTitleColor:YSFRGB(0x76838f) forState:UIControlStateNormal];
    }
    else {
        [_humanServiceText setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    _humanServiceText.titleLabel.font = [UIFont systemFontOfSize:10];
    [_humanServiceText addTarget:self action:@selector(onHumanChat:) forControlEvents:UIControlEventTouchUpInside];
    //商铺
    _shopEntrance = [[UIButton alloc] init];
    _shopEntrance.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_shopEntrance addTarget:self action:@selector(onShopEntranceTap:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_shopEntrance];
    _shopEntranceText = [[UIButton alloc] init];
    [rightButtonView addSubview:_shopEntranceText];
    _shopEntranceText.titleLabel.font = [UIFont systemFontOfSize:10];
    _shopEntranceText.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _shopEntranceText.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        [_shopEntranceText setTitleColor:YSFRGB(0x76838f) forState:UIControlStateNormal];
    }
    else {
        [_shopEntranceText setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [_shopEntranceText setTitle:[QYCustomUIConfig sharedInstance].shopEntranceText forState:UIControlStateNormal];
    [_shopEntranceText addTarget:self action:@selector(onShopEntranceTap:) forControlEvents:UIControlEventTouchUpInside];
    
    //评价
    _evaluation = [[UIButton alloc] init];
    [rightButtonView addSubview:_evaluation];
    [_evaluation addTarget:self action:@selector(onEvaluate) forControlEvents:UIControlEventTouchUpInside];
    _evaluationText = [[UIButton alloc] init];
    [rightButtonView addSubview:_evaluationText];
    _evaluationText.titleLabel.font = [UIFont systemFontOfSize:10];
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        [_evaluationText setTitleColor:YSFRGB(0x76838f) forState:UIControlStateNormal];
    }
    else {
        [_evaluationText setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [_evaluationText addTarget:self action:@selector(onEvaluate) forControlEvents:UIControlEventTouchUpInside];

    //退出按钮
    if ([[QYSDK sharedSDK] customUIConfig].showCloseSessionEntry) {
        _closeSession = [[UIButton alloc] init];
        _closeSession.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *closeSessionImage = nil;
        if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
            closeSessionImage = [[UIImage ysf_imageInKit:@"icon_close_session_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else {
            closeSessionImage = [[UIImage ysf_imageInKit:@"icon_close_session_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }

        [_closeSession setImage:closeSessionImage forState:UIControlStateNormal];
        [_closeSession addTarget:self action:@selector(onCloseSession) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_closeSession];
        
        _closeSessionText = [[UIButton alloc] init];
        [rightButtonView addSubview:_closeSessionText];
        [_closeSessionText setTitle:@"退出" forState:UIControlStateNormal];
        QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
        if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
            [_closeSessionText setTitleColor:YSFRGB(0x76838f) forState:UIControlStateNormal];
        }
        else {
            [_closeSessionText setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        _closeSessionText.titleLabel.font = [UIFont systemFontOfSize:10];
        [_closeSessionText addTarget:self action:@selector(onCloseSession) forControlEvents:UIControlEventTouchUpInside];

        _moreButton = [[UIButton alloc] init];
        _moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *moreImage = nil;
        if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
            moreImage = [[UIImage ysf_imageInKit:@"icon_more_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else {
            moreImage = [[UIImage ysf_imageInKit:@"icon_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [_moreButton setImage:moreImage forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_moreButton];
        
        _moreButtonText = [[UIButton alloc] init];
        [rightButtonView addSubview:_moreButtonText];
        [_moreButtonText setTitle:@"更多" forState:UIControlStateNormal];
        if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
            [_moreButtonText setTitleColor:YSFRGB(0x76838f) forState:UIControlStateNormal];
        }
        else {
            [_moreButtonText setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        _moreButtonText.titleLabel.font = [UIFont systemFontOfSize:10];
        [_moreButtonText addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self initRightCustomButtonStatus];
    //把右侧的两个按钮添加到rightBarButtonItem
    UIBarButtonItem *rightCustomButtonView = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    self.navigationItem.rightBarButtonItem = rightCustomButtonView;
    
    self.view.backgroundColor = YSFRGB(0xf8f8f8);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundView = [[QYCustomUIConfig sharedInstance] sessionBackground];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    singleTapRecognizer.delaysTouchesEnded = NO;
    [self.tableView addGestureRecognizer:singleTapRecognizer];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.tableView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:_refreshControl];
    [self.refreshControl addTarget:self action:@selector(headerRereshing:) forControlEvents:UIControlEventValueChanged];
    
    CGRect inputViewRect = CGRectMake(0, 0, self.view.ysf_frameWidth, YSFTopInputViewHeight);
    BOOL disableInputView = NO;
    if (!disableInputView) {
        self.sessionInputView = [[YSFInputView alloc] initWithFrame:inputViewRect inputType:g_inputStatus];
        _sessionInputView.containerController = self;
        [_sessionInputView setInputActionDelegate:self];
        [self.view addSubview:_sessionInputView];
    }
    
    __weak typeof(self) weakSelf = self;
    [_sessionInputView setActionCallback:^(YSFActionInfo *action) {
        if (action.action == QYActionTypeSend) {
            [weakSelf onSendText:action.title];
        }
        else {
            QYButtonInfo *qyActionInfo = [QYButtonInfo new];
            qyActionInfo.buttonId = action.buttonId;
            qyActionInfo.title = action.title;
            qyActionInfo.userData = action.userData;
            if (weakSelf.buttonClickBlock) {
                weakSelf.buttonClickBlock(qyActionInfo);
            }
        }
    }];
    
    _tipView = [[YSFSessionTipView alloc] initWithFrame:CGRectZero];
    _tipView.delegate = self;
    BOOL reachable = [_reachability isReachable];
    [_tipView setSessionTip:reachable ? YSFSessionTipOK : YSFSessionTipNetworkError];
    [self.view addSubview:_tipView];

    _recordTipView = [[YSFRecordTipView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_recordTipView];
    //会话列表入口一定要在View的top层，所以最后再addSubview
    if ([QYCustomUIConfig sharedInstance].showSessionListEntrance) {
        [self showSessionListEntrance];
    }
    
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    if (![sessionManager shouldRequestService:YES shopId:_shopId])
    {
        YSFServiceSession *session = [sessionManager getOnlineSession:_shopId];
        if (session) {
            _closeSession.hidden = NO;
            _closeSession.enabled = YES;
            _closeSessionText.hidden = NO;
            _closeSessionText.enabled = YES;
            [self changeHumanOrMachineState:session.humanOrMachine operatorEable:session.operatorEable];
            
            if (session.humanOrMachine) {
                [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
                NSDictionary *dict = [sessionManager getEvaluationInfoByShopId:_shopId];
                if (dict) {
                    NSNumber *sessionId = [dict objectForKey:YSFCurrentSessionId];
                    NSString *sessionTimes = [dict objectForKey:YSFSessionTimes];
                    if ([sessionId longLongValue] == session.sessionId) {
                        if ([sessionTimes intValue] == -1) {
                            [self changeEvaluationButtonToDone];
                        }
                        else {
                            [self changeEvaluationButtonToEnable];
                        }
                    }
                }
            }
            else {
                [_sessionInputView setActionInfoArray:session.actionInfoArray];
            }
        }
    }
    
    _quickReplyView = [[YSFQuickReplyContentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.sessionInputView.bounds), 0)];
    _quickReplyView.delegate = self;
    _quickReplyView.onlyMatchFirst = YES;
    _quickReplyView.backgroundColor = [UIColor whiteColor];
    _quickReplyView.layer.shadowOffset = CGSizeMake(0, -1);
    _quickReplyView.layer.shadowColor = YSFColorFromRGBA(0xE2E2E2, 0.5).CGColor;
}

#pragma mark - 快捷回复预览Delegate
- (void)didTapRowAtIndex:(NSUInteger)index data:(YSFQuickReplyKeyWordAndContent *)data
{
    self.sessionInputView.toolBar.inputTextView.text = @"";
    [self.quickReplyView removeFromSuperview];
    [self sendMessage:[YSFMessageMaker msgWithText:data.content]];
}

- (void)setRightButtonViewFrame
{
    if (!_shopEntrance.hidden && !_evaluation.hidden && _closeSession && !_closeSession.hidden) {
        _evaluation.alpha = 0;
        _evaluationText.alpha = 0;
        _closeSession.alpha = 0;
        _closeSessionText.alpha = 0;
        _moreButton.hidden = NO;
        _moreButtonText.hidden = NO;
    }
    else {
        _evaluation.alpha = 1;
        _evaluationText.alpha = 1;
        _closeSession.alpha = 1;
        _closeSessionText.alpha = 1;
        _moreButton.hidden = YES;
        _moreButtonText.hidden = YES;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (_evaluation.hidden && _humanService.hidden && (!_closeSession || _closeSession.hidden)) {
            _shopEntrance.frame = CGRectMake(40, 0, 50, 20);
            _shopEntranceText.frame = CGRectMake(50, 20, 30, 20);
        }
        else {
            _shopEntrance.frame = CGRectMake(0, 0, 50, 20);
            _shopEntranceText.frame = CGRectMake(10, 20, 30, 20);
        }
        if (!_closeSession || _closeSession.hidden) {
            _humanService.frame = CGRectMake(40, 0, 50, 20);
            _humanServiceText.frame = CGRectMake(40, 20, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        }
        else {
            _humanService.frame = CGRectMake(0, 0, 50, 20);
            _humanServiceText.frame = CGRectMake(0, 20, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        }
        _closeSession.frame = CGRectMake(40, 0, 50, 20);
        _closeSessionText.frame = CGRectMake(40, 20, 50, 20);
        _moreButton.frame = CGRectMake(40, 0, 50, 20);
        _moreButtonText.frame = CGRectMake(40, 20, 50, 20);
    }
    else {
        if (_evaluation.hidden && _humanService.hidden && (!_closeSession || _closeSession.hidden)) {
            _shopEntrance.frame = CGRectMake(40, 1, 50, 20);
            _shopEntranceText.frame = CGRectMake(50, 17, 30, 20);
        }
        else {
            _shopEntrance.frame = CGRectMake(0, 1, 50, 20);
            _shopEntranceText.frame = CGRectMake(10, 17, 30, 20);
        }
        if (!_closeSession || _closeSession.hidden) {
            _humanService.frame = CGRectMake(40, 1, 50, 20);
            _humanServiceText.frame = CGRectMake(40, 17, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        }
        else {
            _humanService.frame = CGRectMake(0, 1, 50, 20);
            _humanServiceText.frame = CGRectMake(0, 17, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        }
        _closeSession.frame = CGRectMake(40, 1, 50, 20);
        _closeSessionText.frame = CGRectMake(40, 17, 50, 20);
        _moreButton.frame = CGRectMake(40, 1, 50, 20);
        _moreButtonText.frame = CGRectMake(40, 17, 50, 20);
    }
}

- (void)showSessionListEntrance
{
    UIImageView *sessionListImageView = [UIImageView new];
    self.sessionListImageView = sessionListImageView;
    sessionListImageView.alpha = 0.6;
    sessionListImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIButton *sessionListButton = [UIButton new];
    self.sessionListButton = sessionListButton;
    sessionListButton.backgroundColor = [UIColor clearColor];
    [sessionListButton addTarget:self action:@selector(onTapSessionListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self setSessionListEntranceFrame];
    if ([QYCustomUIConfig sharedInstance].sessionListEntrancePosition) {
        //YES是在右上角
        if ([QYCustomUIConfig sharedInstance].sessionListEntranceImage) {
            sessionListImageView.image = [QYCustomUIConfig sharedInstance].sessionListEntranceImage;
        } else {
            sessionListImageView.image = [UIImage ysf_imageInKit:@"icon_sessionListEntrance_right"];
        }
    } else {
        //NO是在左上角
        if ([QYCustomUIConfig sharedInstance].sessionListEntranceImage) {
            sessionListImageView.image = [QYCustomUIConfig sharedInstance].sessionListEntranceImage;
        } else {
            sessionListImageView.image = [UIImage ysf_imageInKit:@"icon_sessionListEntrance_left"];
        }
    }
    [self.view addSubview:sessionListImageView];
    [self.view addSubview:sessionListButton];
}

- (void)setSessionListEntranceFrame
{
    if ([QYCustomUIConfig sharedInstance].sessionListEntrancePosition) {
        //YES是在右上角
        _sessionListImageView.frame = CGRectMake(YSFUIScreenWidth - 42, YSFNormalNavigationbarHeight + 20, 42, 42);
        _sessionListButton.frame = CGRectMake(YSFUIScreenWidth - 42, YSFNormalNavigationbarHeight + 20, 42, 42);
    } else {
        //NO是在左上角
        _sessionListImageView.frame = CGRectMake(0, YSFNormalNavigationbarHeight + 20, 42, 42);
        _sessionListButton.frame = CGRectMake(0, YSFNormalNavigationbarHeight + 20, 42, 42);
    }
}

- (void)changeHumanOrMachineState:(BOOL)humanOrMachine operatorEable:(BOOL)operatorEable
{
    if (_changeHumanOrRobotBlock) {
        _changeHumanOrRobotBlock(humanOrMachine);
    }
    if (!humanOrMachine) {
        self.sessionInputView.humanOrMachine = NO;
        if (operatorEable) {
            _humanService.hidden = NO;
            _humanServiceText.hidden = NO;
        }
        else {
            _humanService.hidden = YES;
            _humanServiceText.hidden = YES;
        }
        _evaluation.hidden = YES;
        _evaluationText.hidden = YES;
        _closeSession.hidden = YES;
        _closeSessionText.hidden = YES;
    }
    else {
        self.sessionInputView.humanOrMachine = YES;
        _humanService.hidden = YES;
        _humanServiceText.hidden = YES;
        if ([QYCustomUIConfig sharedInstance].showEvaluationEntry) {
            _evaluation.hidden = NO;
            _evaluationText.hidden = NO;
        }
        _closeSession.enabled = YES;
        _closeSession.hidden = NO;
        _closeSessionText.enabled = YES;
        _closeSessionText.hidden = NO;
    }
    [self setRightButtonViewFrame];
}

- (void)changeToWaitingState:(BOOL)robotInQueue
{
    self.sessionInputView.humanOrMachine = !robotInQueue;
    
    _humanService.hidden = YES;
    _humanServiceText.hidden = YES;
    _evaluation.hidden = YES;
    _evaluationText.hidden = YES;
    _closeSession.enabled = YES;
    _closeSession.hidden = NO;
    _closeSessionText.enabled = YES;
    _closeSessionText.hidden = NO;
    [self setRightButtonViewFrame];
}

- (void)changeToNotExsitState:(YSFServiceSession *)session
{
    self.sessionInputView.humanOrMachine = YES;
    
    _humanService.hidden = YES;
    _humanServiceText.hidden = YES;
    _evaluation.hidden = YES;
    _evaluationText.hidden = YES;
    _closeSession.hidden = YES;
    _closeSessionText.hidden = YES;
    [self setRightButtonViewFrame];
    
    [_tipView setSessionTipForNotExist:session.message];
}

- (void)changeToNotExsitAndLeaveMessageClosedState:(YSFServiceSession *)session
{
    [self changeToNotExsitState:session];
    [self disableInputView:@"客服不在线，不支持留言"];
}

- (void)disableInputView:(NSString *)text
{
    [self.sessionInputView changeInputTypeToText];
    self.sessionInputView.toolBar.inputTextView.textColor = [UIColor lightGrayColor];
    self.sessionInputView.toolBar.inputTextView.editable = NO;
    self.sessionInputView.toolBar.voiceBtn.enabled = NO;
    self.sessionInputView.toolBar.emoticonBtn.enabled = NO;
    self.sessionInputView.toolBar.imageButton.enabled = NO;
    self.sessionInputView.toolBar.inputTextView.text = text;
}

//初始化右上角：人工、商铺、评价的状态和显示关系
- (void)initRightCustomButtonStatus
{
    QYCustomUIConfig *uiConfig = [QYSDK sharedSDK].customUIConfig;
    NSString *shopEntranceIcon = nil;
    NSString *humanServiceIcon = nil;
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        shopEntranceIcon = @"icon_shopEntrance_black";
        humanServiceIcon = @"icon_humanService_black";
    }
    else {
        shopEntranceIcon = @"icon_shopEntrance_white";
        humanServiceIcon = @"icon_humanService_white";
    }
    UIImage *image = [[UIImage ysf_imageInKit:shopEntranceIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (uiConfig.shopEntranceImage) {
        [_shopEntrance setImage:uiConfig.shopEntranceImage forState:UIControlStateNormal];
    } else {
        [_shopEntrance setImage:image forState:UIControlStateNormal];
    }
    
    image = [[UIImage ysf_imageInKit:humanServiceIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_humanService setImage:image forState:UIControlStateNormal];
    
    _humanService.hidden = YES;
    _humanServiceText.hidden = YES;
    if ([QYCustomUIConfig sharedInstance].showShopEntrance) {
        _shopEntrance.hidden = NO;
        _shopEntranceText.hidden = NO;
    } else {
        _shopEntrance.hidden = YES;
        _shopEntranceText.hidden = YES;
    }
    
    _closeSession.hidden = YES;
    _closeSessionText.hidden = YES;

    [self changeEvaluationButtonToInit];
    
    [self setRightButtonViewFrame];
}

- (void)changeEvaluationButtonToInit
{
    QYCustomUIConfig *uiConfig = [QYSDK sharedSDK].customUIConfig;
    NSString *evaluationIcon = nil;
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        evaluationIcon = @"icon_evaluation_black";
    }
    else {
        evaluationIcon = @"icon_evaluation_white";
    }
    UIImage *image = [[UIImage ysf_imageInKit:evaluationIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_evaluation setImage:image forState:UIControlStateNormal];

    _evaluation.hidden = YES;
    _evaluationText.hidden = YES;
    [_evaluationText setTitle:@"评价" forState:UIControlStateNormal];
}

- (void)changeEvaluationButtonToEnable
{
    if (_changeEvaluationEnabledBlock) {
        _changeEvaluationEnabledBlock(YES);
    }
    if (![QYCustomUIConfig sharedInstance].showEvaluationEntry) {
        return;
    }
    _evaluation.hidden = NO;
    _evaluationText.hidden = NO;
    
    _evaluation.enabled = YES;
    _evaluationText.enabled = YES;
    [_evaluationText setTitle:@"评价" forState:UIControlStateNormal];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    NSString *evaluationIcon = nil;
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        evaluationIcon = @"icon_evaluation_black";
    }
    else {
        evaluationIcon = @"icon_evaluation_white";
    }
    UIImage *image = [[UIImage ysf_imageInKit:evaluationIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_evaluation setImage:image forState:UIControlStateNormal];
}

- (void)changeEvaluationButtonToDone
{
    if (_changeEvaluationEnabledBlock) {
        _changeEvaluationEnabledBlock(NO);
    }
    if (![QYCustomUIConfig sharedInstance].showEvaluationEntry) {
        return;
    }
    _evaluation.hidden = NO;
    _evaluationText.hidden = NO;
    _evaluation.enabled = NO;
    _evaluationText.enabled = NO;
    [_evaluationText setTitle:@"已评价" forState:UIControlStateNormal];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    NSString *evaluationIcon = nil;
    if (uiConfig.rightBarButtonItemColorBlackOrWhite) {
        evaluationIcon = @"icon_evaluation_done_black";
    }
    else {
        evaluationIcon = @"icon_evaluation_done_white";
    }
    UIImage *image = [[UIImage ysf_imageInKit:evaluationIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_evaluation setImage:image forState:UIControlStateNormal];
}

- (void)onShopEntranceTap:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onTapShopEntrance)]) {
        [_delegate onTapShopEntrance];
    }
}

- (void)onCloseSession
{
    [self onCloseSessionWith:YES showQuitWaitingBlock:nil];
}

- (void)onCloseSessionWith:(BOOL)quitSessionViewController showQuitWaitingBlock:(QYQuitWaitingBlock)showQuitWaitingBlock
{
    [_popTipView dismissAnimated:YES];
    __weak typeof(self) weakSelf = self;
    YSFAlertController * alertController;
    if ([[[QYSDK sharedSDK] sessionManager] getSessionStateType:_shopId] == YSFSessionStateTypeWaiting) {
        alertController = [YSFAlertController alertWithTitle:nil message:@"确认退出排队？"];
        [alertController addCancelActionWithHandler:nil];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf sendCloseSessionCustomMessage:YES quitSessionViewController:quitSessionViewController
              showQuitWaitingBlock:showQuitWaitingBlock];
        }]];
    }
    else {
        alertController = [YSFAlertController alertWithTitle:nil message:@"确认退出对话？"];
        [alertController addCancelActionWithHandler:nil];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf sendCloseSessionCustomMessage:NO quitSessionViewController:quitSessionViewController
              showQuitWaitingBlock:showQuitWaitingBlock];
        }]];
    }
    
    [alertController showWithSender:nil controller:self animated:YES completion:nil];
}

- (void)onMore:(id)sender
{
    UIView *tipView = [UIView new];
    tipView.userInteractionEnabled = YES;
    tipView.frame = CGRectMake(0, 0, 90, 100);
    UIButton *evaluation = [UIButton new];
    evaluation.frame = CGRectMake(0, 0, 90, 50);
    evaluation.titleLabel.font = [UIFont systemFontOfSize:15];
    [evaluation setImage:_evaluation.imageView.image forState:UIControlStateNormal];
    [evaluation setTitle:_evaluationText.titleLabel.text forState:UIControlStateNormal];
    evaluation.enabled = _evaluation.enabled;
    if (evaluation.titleLabel.text.length == 3) {
        tipView.ysf_frameWidth = 104;
        evaluation.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
        evaluation.titleEdgeInsets = UIEdgeInsetsMake(0, 19, 0, 0);
    }
    else {
        evaluation.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        evaluation.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }

    [evaluation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [evaluation addTarget:self action:@selector(onEvaluate) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:evaluation];
    UIButton *close = [UIButton new];
    close.frame = CGRectMake(0, 50, 90, 50);
    close.titleLabel.font = [UIFont systemFontOfSize:15];
    [close setImage:_closeSession.imageView.image forState:UIControlStateNormal];
    [close setTitle:@"退出" forState:UIControlStateNormal];
    close.enabled = _closeSession.enabled;
    close.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    close.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [close setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(onCloseSession) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:close];
    
    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameWidth = tipView.ysf_frameWidth;
    splitLine.ysf_frameTop = 50;
    [tipView addSubview:splitLine];
    
    _popTipView = [[YSFPopTipView alloc] initWithCustomView:tipView];
    _popTipView.backgroundColor = [UIColor whiteColor];
    _popTipView.maskColor = YSFRGBA(0x000000, 0.4);
    _popTipView.borderColor = [UIColor lightGrayColor];
    _popTipView.cornerRadius = 3;
    _popTipView.has3DStyle = NO;
    _popTipView.hasShadow = NO;
    _popTipView.dismissTapAnywhere = YES;
    _popTipView.topMargin = 10;
    _popTipView.sidePadding = 10;
    [_popTipView presentPointingAtView:_moreButtonText inView:self.view animated:YES];
}

- (void)onTapSessionListButton:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onTapSessionListEntrance)]) {
        [_delegate onTapSessionListEntrance];
    }
}

- (void)onEvaluate
{
    YSFLogApp(@"");

    [_popTipView dismissAnimated:YES];
    NSDictionary *dict = [[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId];
    long long sessionId = ((NSNumber *)[dict objectForKey:YSFCurrentSessionId]).longLongValue;
    NSString *evaluationMessageThanks = [dict ysf_jsonString:YSFApiKeyEvaluationMessageThanks];
    NSDictionary *evaluationData = [dict objectForKey:YSFEvaluationData];

    [self showEvaluationViewController:nil sessionId:sessionId evaluationData:evaluationData
               evaluationMessageThanks:evaluationMessageThanks];
}

- (void)showEvaluationResult:(BOOL)needShow sessionId:(long long)sessionId
             kaolaTipContent:(NSString *)kaolaTipContent
                 evaluationMessageThanks:(NSString *)evaluationMessageThanks
              evaluationText:(NSString *)evaluationText
                      updatedMessage:(YSF_NIMMessage *)updatedMessage
{
    //evaluationViewControlerWillAppear 里面的 [self.view endEditing:YES];，在后台的时候，不会触发键盘变更事件，
    //导致键盘无法正常弹回，这里补救一下 相关问题单号：YSF-14096
    [_sessionInputView inputBottomViewHeightToZero];
    [_sessionInputView addKeyboardObserver];
    
    NSMutableDictionary *shopDict = [[[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId] mutableCopy];
    [shopDict setValue:@(NO) forKey:YSFApiEvaluationAutoPopup];
    [[[QYSDK sharedSDK] sessionManager] setEvaluationInfo:shopDict shopId:_shopId];
    
    if (!needShow) {
        return;
    }
    
    if (shopDict) {
        [shopDict setValue:@(3) forKey:YSFSessionStatus];
        [[[QYSDK sharedSDK] sessionManager] setEvaluationInfo:shopDict shopId:_shopId];
    }
    
    YSFEvaluationTipObject *customMachine = [[YSFEvaluationTipObject alloc] init];
    customMachine.command = YSFCommandEvaluationTip;
    customMachine.kaolaTipContent = kaolaTipContent;
    if (evaluationMessageThanks.length > 0) {
        customMachine.tipContent = evaluationMessageThanks;
    }
    else {
        customMachine.tipContent = @"您对我们的服务评价为";
    }
    customMachine.tipContent = [customMachine.tipContent stringByAppendingString:@"： "];
    customMachine.tipResult = evaluationText;
    
    long long current_sessionId = [[shopDict objectForKey:YSFCurrentSessionId] longLongValue];
    if (current_sessionId == sessionId) {
        [self changeEvaluationButtonToDone];
        
        if (shopDict) {
            [shopDict setValue:@"-1" forKey:YSFSessionTimes];
            [[[QYSDK sharedSDK] sessionManager] setEvaluationInfo:shopDict shopId:self.shopId];
        }
    }
    
    long long currentInviteEvaluationSessionId = 0;
    if (_currentInviteEvaluationMessage) {
        YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)_currentInviteEvaluationMessage.messageObject;
        YSFInviteEvaluationObject * evaluationObject = (YSFInviteEvaluationObject *)object.attachment;
        currentInviteEvaluationSessionId = evaluationObject.sessionId;
    }
    
    if (updatedMessage || (_currentInviteEvaluationMessage && currentInviteEvaluationSessionId == current_sessionId)) {
        YSF_NIMMessage *tmpUpdatedMessage = nil;
        if (updatedMessage) {
            tmpUpdatedMessage = updatedMessage;
        }
        else {
            tmpUpdatedMessage = self.currentInviteEvaluationMessage;
        }
        YSF_NIMCustomObject *customObject = [[YSF_NIMCustomObject alloc] init];
        customObject.attachment = customMachine;
        tmpUpdatedMessage.messageObject = customObject;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:tmpUpdatedMessage forSession:_session completion:nil];
        if (tmpUpdatedMessage == _currentInviteEvaluationMessage) {
            self.currentInviteEvaluationMessage = nil;
        }
    }
    else {
        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:customMachine];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage
                                                       forSession:_session addUnreadCount:NO completion:nil];
    }
}

- (void)evaluationViewControlerWillAppear
{
    [self.view endEditing:YES];
    [_sessionInputView removeKeyboardObserver];
}

- (void)showEvaluationViewController:(YSF_NIMMessage *)updatedMessage sessionId:(long long)sessionId evaluationData:(NSDictionary *)evaluationData
             evaluationMessageThanks:(NSString *)evaluationMessageThanks
{
    if (!sessionId) {
        return;
    }
    
    [self evaluationViewControlerWillAppear];
    
    __weak typeof(self) weakSelf = self;
    EvaluationCallback evaluationCallback = ^(BOOL done, NSString *evaluationText){
        [weakSelf showEvaluationResult:done sessionId:sessionId kaolaTipContent:@"" evaluationMessageThanks:evaluationMessageThanks evaluationText:evaluationText updatedMessage:updatedMessage];
    };
    YSFEvaluationViewController *vc = [[YSFEvaluationViewController alloc] initWithEvaluationDict:evaluationData shopId:_shopId sessionId:sessionId evaluationCallback:evaluationCallback];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)initSessionDatasource
{
    NSInteger limit = 20;
    NSTimeInterval showTimestampInterval = 5 * 60.0;
    _sessionDatasource = [[YSFSessionMsgDatasource alloc] initWithSession:_session showTimeInterval:showTimestampInterval limit:limit];
    _sessionDatasource.delegate = self;
    [_sessionDatasource resetMessages];
}

- (void)makeHandlerAndDataSource
{
    _layoutManager = [[YSFSessionViewLayoutManager alloc] initWithInputView:self.sessionInputView tableView:self.tableView];
    
    //数据
    [self initSessionDatasource];

    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] conversationManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] loginManager] addDelegate:self];
    [[QYSDK sharedSDK] infoManager].delegate = self;
    
    [_reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkChanged:)
                                                 name:YSFReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAVSessionChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidHide:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)willResignActive:(NSNotification*)notification
{
    YSFLogApp(@"notification: %@", notification);
    
    [self cancelRecordAudio];
}

- (void)didEnterBackground:(NSNotification*)notification
{
    YSFLogApp(@"notification: %@", notification);
    
    [self cancelRecordAudio];
}

- (void)cancelRecordAudio
{
    [_sessionInputView setRecordPhase:AudioRecordPhaseCancelling];
    [_sessionInputView setRecordPhase:AudioRecordPhaseEnd];
    [[YSF_NIMSDK sharedSDK].mediaManager stopPlay];
}

- (void)viewWillAppear:(BOOL)animated
{
    YSFLogApp(@"");

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    YSFLogApp(@"");

    [super viewDidDisappear:animated];
    NSString *text = [self.sessionInputView inputText];
    if (!self.sessionInputView.toolBar.inputTextView.editable) {
        text = @"";
    }
    [[[QYSDK sharedSDK] infoManager] setCachedText:text shopId:_shopId];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.sessionBackground) {
        self.sessionBackground.frame = self.view.frame;
    }
    [self setRightButtonViewFrame];
    [self changeLeftBarBadge:[[YSF_NIMSDK sharedSDK] conversationManager].allUnreadCount];
    BOOL isFirstLayout = CGRectEqualToRect(_layoutManager.viewRect, CGRectZero);
    [_layoutManager setViewRect:self.view.frame];
    
    if (self.quickReplyView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.quickReplyView.ysf_frameBottom = self.sessionInputView.ysf_frameTop;
        }];
    }
    
//    //补丁
//    if ([UIApplication sharedApplication].statusBarHidden || (self.presentedViewController != nil && [self.presentedViewController isKindOfClass:[YSFGalleryViewController class]])) {
//    }
//    else{
//        [self.tableView ysf_scrollToBottom:YES];
//    }
    
    self.sessionInputView.ysf_frameLeft = 0;
    self.sessionInputView.ysf_frameWidth = self.view.ysf_frameWidth;
    self.sessionInputView.ysf_frameBottom = self.view.ysf_frameHeight;
    CGFloat bottomMargin = [[QYCustomUIConfig sharedInstance] bottomMargin];
    if (bottomMargin > 0) {
        self.sessionInputView.ysf_frameBottom -= bottomMargin;
    } else {
        if (@available(iOS 11, *)) {
            self.sessionInputView.ysf_frameBottom -= self.view.safeAreaInsets.bottom;
        }
    }
    if (@available(iOS 11, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_tipView setNeedsLayout];
    _tipView.ysf_frameLeft        = _tableView.ysf_frameLeft;
    if (self.navigationController.navigationBar.translucent) {
        _tipView.ysf_frameTop         = self.navigationController.navigationBar.ysf_frameBottom;
    }
    else {
        _tipView.ysf_frameTop         = 0;
    }
    _tipView.ysf_frameWidth       = _tableView.ysf_frameWidth;
    _tipView.ysf_frameHeight      = [_tipView getTipLabelHeight] + 18;
    UIEdgeInsets contentInset = _tableView.contentInset;
    if (_tipView.hidden) {
        contentInset.top = _tipView.ysf_frameTop;
    }
    else {
        contentInset.top = _tipView.ysf_frameBottom;
    }

    contentInset.bottom = 0;
    _tableView.contentInset = contentInset;
    _tableView.scrollIndicatorInsets = contentInset;
    _recordTipView.frame     = _tipView.frame;
    [self setSessionListEntranceFrame];
    
    if (isFirstLayout) {
        CGFloat safeAreaBottom = 0;
        if (@available(iOS 11, *)) {
            safeAreaBottom = self.view.safeAreaInsets.bottom;
        }
        _tableView.ysf_frameHeight -= safeAreaBottom;
        
        for (id model in [_sessionDatasource modelArray]) {
            if ([model isKindOfClass:[YSFMessageModel class]]) {
                [(YSFMessageModel *)model cleanCache];
            }
        }
        [_tableView reloadData];
        [_tableView ysf_scrollToBottom:YES];
    }
}
//最后一条消息是否是访客分流信息并且能够点击
- (BOOL)isLastMessageKFBypassNotificationAndEnable
{
    YSF_NIMMessage *lastMessage = [self getLastMessage];
    if (lastMessage && lastMessage.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = lastMessage.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
            YSFKFBypassNotification *notification = customObject.attachment;
            if (!notification.disable) {
                return YES;
            }
        }
    }
    return NO;
}
//最后一条消息是否是访客分流信息
- (BOOL)isLastMessageKFBypassNotification
{
    YSF_NIMMessage *lastMessage = [self getLastMessage];
    if (lastMessage && lastMessage.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = lastMessage.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
            return YES;
        }
    }
    return NO;
}
//恢复访客分流状态为可点击状态
- (void)resetKFBypassNotificationStatus
{
    if ([self isLastMessageKFBypassNotification]) {
        YSF_NIMMessage *lastMessage = [self getLastMessage];
        YSF_NIMCustomObject *customObject = lastMessage.messageObject;
        YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
        notification.disable = NO;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:lastMessage forSession:_session completion:nil];
    }
}

- (YSF_NIMMessage *)getLastMessage
{
    //这里一定要去取本地存储的message，recentSession中的lastMesaage由于是异步存储存在问题不同步
    YSF_NIMMessage *lastMessage = [YSF_NIMMessage new];
    id model = [[_sessionDatasource modelArray] lastObject];
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        lastMessage = ((YSFMessageModel *)model).message;
    }
    return lastMessage;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sessionDatasource msgCount];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    id model = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        cell = [YSFMessageCellMaker cellInTable:tableView
                                 forMessageMode:model];
        [(YSFMessageCell *)cell setMessageDelegate:self];
    }
    else if ([model isKindOfClass:[YSFTimestampModel class]])
    {
        cell = [YSFMessageCellMaker cellInTable:tableView
                                   forTimeModel:model];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    id modelInArray = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[YSFMessageModel class]])
    {
        YSFMessageModel *model = (YSFMessageModel *)modelInArray;
        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
        
        if (model.message.messageType == YSF_NIMMessageTypeCustom) {
            id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(model.message.messageObject) attachment];
            if ([attachment isMemberOfClass:[YSFMachineResponse class]]) {
                NSRange range = [model.message.messageId rangeOfString:@"#"];
                long long ysfSessionId = 0;
                if (range.location != NSNotFound)
                {
                    ysfSessionId = [[model.message.messageId substringToIndex:range.location] longLongValue];
                }
                YSFMachineResponse *machineResponse = (YSFMachineResponse *)attachment;
                YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
                YSFServiceSession *session = [sessionManager getOnlineOrWaitingSession:_shopId];
                machineResponse.shouldShow = (session.sessionId == ysfSessionId || session.robotSessionId == ysfSessionId);
                [model cleanCache];
            }
        }
        
        [self layoutConfig:model];
        CGSize size = model.contentSize;
        
        //assert(!CGSizeEqualToSize(size, CGSizeZero));
        
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
    }
    else if ([modelInArray isKindOfClass:[YSFTimestampModel class]])
    {
        cellHeight = [(YSFTimestampModel *)modelInArray height];
    }
    else
    {
        //assert(false);
    }
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - YSFAppInfoManagerDelegate
- (void)didCreateAccountSuccessfully
{
    //创建账号成功后重新进行初始化等待登录成功请求客服
    NSString *bid = [[QYSDK sharedSDK] infoManager].accountInfo.bid;
    if (bid) {
        _shopId = bid;
        [self initSession];
        [self initSessionDatasource];
    }
}

#pragma mark - 消息收发接口
- (void)sendMessage:(YSF_NIMMessage *)message
{
    [_inputtingMessage stop];
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    if ([sessionManager getOnlineSession:_shopId] && [sessionManager getOnlineSession:_shopId].humanOrMachine) {
        NSMutableDictionary *shopDict = [[[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId] mutableCopy];
        if (shopDict) {
            NSString *sessionTimesStr = [shopDict objectForKey:YSFSessionTimes];
            if (sessionTimesStr) {
                if ([sessionTimesStr isEqualToString:@"0"]) {
                    sessionTimesStr = @"1";
                }
                else if ([sessionTimesStr isEqualToString:@"2"]) {
                    sessionTimesStr = @"3";
                }
                [shopDict setValue:sessionTimesStr forKey:YSFSessionTimes];
                [[[QYSDK sharedSDK] sessionManager] setEvaluationInfo:shopDict shopId:_shopId];
            }
        }
    }
    
    [[[YSF_NIMSDK sharedSDK] chatManager] sendMessage:message toSession:_session error:nil];
}

//发送消息
- (void)willSendMessage:(YSF_NIMMessage *)message
{
    if ([message.session isEqual:_session]) {
        if ([self findModel:message]) {
            [self uiUpdateMessage:message];
        }else{
            [self uiAddMessages:@[message]];
        }
        
    }
}

//发送结果
- (void)sendMessage:(YSF_NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session])
    {
        YSFMessageModel *model = [self makeModel:message];
        NSInteger index = [self.sessionDatasource indexAtModelArray:model];
        [self.layoutManager updateCellAtIndex:index model:model];
        
        if (error)
        {
            if (![[YSFReachability reachabilityForInternetConnection] isReachable])
            {
                [_tipView setSessionTip:YSFSessionTipNetworkError];
            }
        }
        else
        {
            [_tipView setSessionTip:YSFSessionTipNetworkOK];
        }
    }
}

//发送进度
-(void)sendMessage:(YSF_NIMMessage *)message progress:(CGFloat)progress
{
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    YSF_NIMSession *session = [(YSF_NIMMessage *)[messages firstObject] session];
    if (![session isEqual:self.session] || !messages.count){
        return;
    }
    [self uiAddMessages:messages];
    [[YSF_NIMSDK sharedSDK].conversationManager markAllMessageReadInSession:self.session];
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    [sessionManager reportPushMessageReadedStatus];
    
    YSF_NIMMessage *message = [messages firstObject];
    id customObject = message.messageObject;
    if ([customObject isMemberOfClass:[YSF_NIMCustomObject class]]) {
        id object = ((YSF_NIMCustomObject *)customObject).attachment;
        if ([object isMemberOfClass:[YSFBotForm class]]) {
            [self displayFillInBotForm:message];
        }
        else if ([object isMemberOfClass:[YSFBotCustomObject class]]) {
            [self showBotCustomViewController:(YSFBotCustomObject *)object];
        }
    }

    if ([sessionManager getOnlineSession:_shopId] && [sessionManager getOnlineSession:_shopId].humanOrMachine) {
        //收到XXX为您服务后发送一次
        if ([customObject isMemberOfClass:[YSF_NIMCustomObject class]]) {
            id object = ((YSF_NIMCustomObject *)customObject).attachment;
            if (g_sessionId != [sessionManager getOnlineSession:_shopId].sessionId && [object isMemberOfClass:[YSFStartServiceObject class]]) {
                g_sessionId = [sessionManager getOnlineSession:_shopId].sessionId;
                [self sendCommodityInfoRequest:YES];
            }
        }
        
        NSMutableDictionary *shopDict = [[[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId] mutableCopy];
        if (shopDict) {
            NSString *sessionTimesStr = [shopDict objectForKey:YSFSessionTimes];
            if (sessionTimesStr) {
                if ([sessionTimesStr isEqualToString:@"1"]) {
                    sessionTimesStr = @"2";
                }
                else if ([sessionTimesStr isEqualToString:@"3"]) {
                    sessionTimesStr = @"4";
                }
                [shopDict setValue:sessionTimesStr forKey:YSFSessionTimes];
                [[[QYSDK sharedSDK] sessionManager] setEvaluationInfo:shopDict shopId:_shopId];
                
                if ([sessionTimesStr isEqualToString:@"4"]) {
                    if (!self.presentedViewController) {
                        [_evaluation animation_shakeImageWithDuration];
                    }
                }
            }
        }
    }
}

- (void)onUpdateMessage:(YSF_NIMMessage *)message
{
    YSF_NIMSession *session = [message session];
    if (![session isEqual:self.session]){
        return;
    }
    [self uiUpdateMessage:message];
}

- (void)onAddMessage:(YSF_NIMMessage *)message
{
    YSF_NIMSession *session = [message session];
    if (![session isEqual:self.session]){
        return;
    }
    
    if (message.messageType == YSF_NIMMessageTypeCustom) {
        id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(message.messageObject) attachment];
        if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]]) {
            _currentInviteEvaluationMessage = message;
            [self showEvaluaViewController];
        }
        else if ([attachment isMemberOfClass:[YSFKFBypassNotification class]]) {
            [self showBypassViewController:message];
        }
    }
    
    [self uiAddMessages:@[message]];
    [[YSF_NIMSDK sharedSDK].conversationManager markAllMessageReadInSession:self.session];
}

- (BOOL)showEvaluaViewController
{
    BOOL evaluationAutoPopup = NO;
    NSMutableDictionary *evalueDict = [[[[QYSDK sharedSDK] infoManager] dictByKey:YSFEvalution] mutableCopy];
    if (evalueDict) {
        NSMutableDictionary *shopDict = [[evalueDict objectForKey:_shopId] mutableCopy];
        evaluationAutoPopup = [[shopDict objectForKey:YSFApiEvaluationAutoPopup] boolValue];
        if (evaluationAutoPopup)
        {
            NSDictionary *dict = [[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId];
            NSString *messageId = [dict objectForKey:YSFApiEvaluationAutoPopupMessageID];
            long long sessionId = ((NSNumber *)[dict objectForKey:YSFApiEvaluationAutoPopupSessionId]).longLongValue;
            NSString *evaluationMessageThanks = [dict ysf_jsonString:YSFApiEvaluationAutoPopupEvaluationMessageThanks];
            NSDictionary *evaluationData = [dict objectForKey:YSFApiEvaluationAutoPopupEvaluationData];
            YSF_NIMMessage *message = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:messageId forSession:_session];
            [self showEvaluationViewController:message sessionId:sessionId evaluationData:evaluationData
                       evaluationMessageThanks:evaluationMessageThanks];
        }
    }

    return evaluationAutoPopup;
}

- (void)showBypassViewController:(YSF_NIMMessage *)message
{
    if ([QYCustomUIConfig sharedInstance].bypassDisplayMode == QYBypassDisplayModeNone) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(message.messageObject) attachment];
    YSFBypassViewController *vc = [[YSFBypassViewController alloc]
                                   initWithByPassNotificatioin:(YSFKFBypassNotification *)attachment
                                        callback:^(BOOL done, NSDictionary *bypassDict) {
        if (done) {
            [weakSelf requestByBypassDict:message entryDict:bypassDict];
        }
    }];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)showBotCustomViewController:(YSFBotCustomObject *)botCustomObject
{
    if ([QYCustomActionConfig sharedInstance].showBotCustomInfoBlock) {
        [QYCustomActionConfig sharedInstance].showBotCustomInfoBlock(botCustomObject.customObject);
    }
}

- (void)fetchMessageAttachment:(YSF_NIMMessage *)message progress:(CGFloat)progress
{
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}

- (void)fetchMessageAttachment:(YSF_NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}


#pragma mark - YSF_NIMConversationManagerDelegate
- (void)messagesDeletedInSession:(YSF_NIMSession *)session{
    [self.sessionDatasource resetMessages];
    [self.tableView reloadData];
}

- (void)didAddRecentSession:(YSF_NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didUpdateRecentSession:(YSF_NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didRemoveRecentSession:(YSF_NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}


- (void)changeUnreadCount:(YSF_NIMRecentSession *)recentSession
         totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session isEqual:self.session]) {
        return;
    }
    [self changeLeftBarBadge:totalUnreadCount];
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount{
    _leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    _leftBarView.badgeView.hidden = !unreadCount;
}

#pragma mark - NIMLoginDelegate
- (void)onLogin:(YSF_NIMLoginStep)step
{
    YSFLogApp(@"step: %@", @(step));

    //如果在会话界面内监听到同步完成,主动请求一次客服
    if (step == YSF_NIMLoginStepSyncOK && _hasRequested)
    {
        //目前快速进去会话窗口，可能出现链接失败，延后两秒尽量规避；
        //不延后的话，requestServiceIfNeeded时可能刚好处在延时2秒提示请求结果的过程中
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
            [sessionManager clearByShopId:weakSelf.shopId];
            [self clearSessionState];
            [weakSelf requestServiceIfNeeded:NO onlyManual:NO];
        });
    }
}

-(void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [_sessionInputView inputBottomViewHeightToZero];
}

#pragma mark - Private

- (void)layoutConfig:(YSFMessageModel *)model
{
    CGFloat contentWidth = self.tableView.ysf_frameWidth;
    if (@available(iOS 11, *)) {
        contentWidth -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    [model calculateContent:contentWidth];
}


- (YSFMessageModel *)makeModel:(YSF_NIMMessage *)message{
    YSFMessageModel *model = [self findModel:message];
    if (!model) {
        model = [[YSFMessageModel alloc] initWithMessage:message];
    }
    [self layoutConfig:model];
    return model;
}

- (YSFMessageModel *)findModel:(YSF_NIMMessage *)message{
    YSFMessageModel *model;
    for (YSFMessageModel *item in self.sessionDatasource.modelArray.reverseObjectEnumerator.allObjects) {
        if ([item isKindOfClass:[YSFMessageModel class]] && [item.message isEqual:message]) {
            model = item;
            //防止那种进了会话又退出去再进来这种行为，防止SDK里回调上来的message和会话持有的message不是一个，导致刷界面刷跪了的情况
            model.message = message;
        }
    }
    return model;
}


- (void)headerRereshing:(id)sender
{
    __weak YSFSessionViewLayoutManager *layoutManager = self.layoutManager;
    __weak UIRefreshControl *refreshControl = self.refreshControl;
    [self.sessionDatasource loadHistoryMessagesWithComplete:^(NSInteger index, NSError *error) {
        [layoutManager reloadDataToIndex:index withAnimation:NO];
        [refreshControl endRefreshing];
    }];
}
#pragma marlk - 通知
- (void)messageDataIsReady{
    [self.tableView reloadData];
    [self.tableView ysf_scrollToBottom:NO];
}

#pragma mark - NIMMediaManagerDelegate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (filePath && error == nil) {
        _sessionInputView.recording = YES;
    }
    else{
        [self onRecordFailed:error];
    }
}

- (void)sendAudio:(NSString *)filePath
{
    YSF_NIMMessage *messageAudio = [YSFMessageMaker msgWithAudio:filePath];
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    if ([sessionManager getOnlineSession:_shopId] && ![sessionManager getOnlineSession:_shopId].humanOrMachine) {
        YSF_NIMSession *session = [YSF_NIMSession session:_shopId type:YSF_NIMSessionTypeYSF];
        messageAudio.from = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
        NSError *error = [messageAudio prepareForSend];
        if (error) {
            return;
        }
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:messageAudio
                                                       forSession:session addUnreadCount:NO completion:nil];
        messageAudio.isDeliveried = NO;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:messageAudio forSession:_session completion:nil];
        [[KFAudioToTextHandler sharedInstance] addMessage:messageAudio.from messageId:messageAudio.messageId];
        __weak typeof(self) weakSelf = self;
        [[[YSF_NIMSDK sharedSDK] resourceManager] upload:filePath progress:nil
                  completion:^(NSString *urlString, NSError *error) {
                      YSF_NIMAudioToTextOption *option = [YSF_NIMAudioToTextOption new];
                      option.url = urlString;
                      option.filepath = filePath;
                      [[[YSF_NIMSDK sharedSDK] mediaManager] transAudioToText:option
                               result:^(NSError *error,NSString *text){
                                   [[KFAudioToTextHandler sharedInstance] removeMessage:messageAudio.messageId];

                                   if (!error) {
                                       YSF_NIMMessage *messageText = [YSFMessageMaker msgWithText:text];
                                       messageText.messageId = messageAudio.messageId;
                                       messageText.serialID = messageAudio.serialID;
                                       messageText.from = messageAudio.from;
                                       [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:messageAudio];
                                       [weakSelf sendMessage:messageText];
                                   }
                                   else {
                                       messageAudio.isDeliveried = NO;
                                       [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:messageAudio forSession:weakSelf.session completion:nil];
                                       UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
                                       [topmostWindow ysf_makeToast:@"语音转文字失败" duration:2.0 position:YSFToastPositionCenter];
                                   }
                               }];
                      
                  }];
    }
    else {
        [self sendMessage:messageAudio];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendAudio:filePath];
        }
        else{
            [self showRecordFileNotSendReason];
        }
    } else {
        [self onRecordFailed:error];
    }
    _sessionInputView.recording = NO;
}

- (void)recordAudioDidCancelled {
    _sessionInputView.recording = NO;
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    [_sessionInputView updateAudioRecordTime:currentTime];
}

- (void)recordAudioInterruptionBegin {
    [[YSF_NIMSDK sharedSDK].mediaManager cancelRecord];
}


#pragma mark - 录音相关接口
- (void)onRecordFailed:(NSError *)error{}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    return YES;
}

- (void)showRecordFileNotSendReason{}


#pragma mark - NIMInputActionDelegate

- (void)SendInputtingMessage
{
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    BOOL switchOpen = [YSFSystemConfig sharedInstance:_shopId].switchOpen;
    CGFloat sendingRate = [YSFSystemConfig sharedInstance:_shopId].sendingRate;

    if (session && session.humanOrMachine && switchOpen && _inputtingMessage.isStopped && self.lastMessageContent) {
        __weak typeof(self) weakSelf = self;
        [_inputtingMessage start:dispatch_get_main_queue() interval:sendingRate repeats:NO block:^{
            if (!weakSelf.inputtingMessage.isStopped && weakSelf.lastMessageContent) {
                [weakSelf sendSendInputtingMessageRequest:weakSelf.lastMessageContent sessionId:session.sessionId sendingRate:sendingRate];
            }
        }];
    }
}

- (void)sendSendInputtingMessageRequest:(NSString *)lastMessageContent sessionId:(long long)sessionId sendingRate:(CGFloat)sendingRate
{
    YSFSendInputtingMessageRequest *request = [[YSFSendInputtingMessageRequest alloc] init];
    request.sendingRate = sendingRate;
    request.sessionId = sessionId;
    request.content = lastMessageContent;
    request.endTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"%@", self.lastMessageContent);
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {}];
    self.lastMessageContent = nil;
}

- (void)SendSearchQuestion
{
    if (![YSFSearchQuestionSetting sharedInstance:_shopId].switchOpen) {
        return;
    }
    
    if (_lastMessageContent.length > 0 && _lastMessageContent.length <= 10) {
        YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineOrWaitingSession:_shopId];
        CGFloat sendingRate = [YSFSearchQuestionSetting sharedInstance:_shopId].sendingRate;
        
        if (session && (!session.humanOrMachine || session.robotInQueue) && _inputtingMessage.isStopped && self.lastMessageContent) {
            __weak typeof(self) weakSelf = self;
            [_inputtingMessage start:dispatch_get_main_queue() interval:sendingRate repeats:NO block:^{
                if (!weakSelf.inputtingMessage.isStopped && weakSelf.lastMessageContent) {
                    [weakSelf sendSearchQuestionRequest:weakSelf.lastMessageContent sessionId:session.sessionId sendingRate:sendingRate];
                }
            }];
        }
    } else {
        [self clearQuickReplyView];
    }
}

- (void)clearQuickReplyView
{
    [self.quickReplyView removeFromSuperview];
    self.quickReplyView.ysf_frameHeight = 0;
    self.quickReplyView.ysf_frameBottom = self.sessionInputView.ysf_frameTop;
}

- (void)sendSearchQuestionRequest:(NSString *)lastMessageContent sessionId:(long long)sessionId sendingRate:(CGFloat)sendingRate
{
    YSFSendSearchQuestionRequest *request = [[YSFSendSearchQuestionRequest alloc] init];
    request.sessionId = sessionId;
    request.content = lastMessageContent;

    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {}];
    self.lastMessageContent = nil;
}

- (void)onTextChanged:(id)sender
{
    self.lastMessageContent = _sessionInputView.toolBar.inputTextView.text;
    [self SendInputtingMessage];
    [self SendSearchQuestion];
}

- (BOOL)onSendText:(NSString *)text
{
    BOOL shouldSend = [self requestServiceWithTip];
    if (!shouldSend) {
        return NO;
    }
    
    if (text) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if (text.length == 0) {
        UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
        [topmostWindow ysf_makeToast:@"不能发送空白消息" duration:2.0 position:YSFToastPositionCenter];
        self.sessionInputView.toolBar.inputTextView.text = @"";

        return false;
    }
    YSF_NIMMessage *message = [YSFMessageMaker msgWithText:text];
    [self sendMessage:message];
    
    self.lastMessageContent = nil;
    [self clearQuickReplyView];
    
    return YES;
}

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{}

- (void)onCancelRecording
{
    [[YSF_NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording
{
    [[YSF_NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording
{
    BOOL shouldSend = [self requestServiceWithTip];
    if (!shouldSend) {
        return;
    }
    
    [[YSF_NIMSDK sharedSDK].mediaManager recordAudioForDuration:60.f
                                               withDelegate:self];
}

#pragma mark - Cell事件
- (void)onTapCell:(YSFKitEvent *)event
{
    __block BOOL handled = NO;
    NSString *eventName = event.eventName;
    YSF_NIMMessage *message = event.message;
    
    if ([eventName isEqualToString:YSFKitEventNameReloadData])
    {
        YSFMessageModel *model = [self makeModel:message];
        BOOL shouldAutoScroll = NO;
        NSInteger index = [self.sessionDatasource indexAtModelArray:model];
        if (index > -1) {
            shouldAutoScroll = (index == [self.sessionDatasource msgCount] - 1) && [_tableView ysf_isInBottom];
        }
        [_tableView reloadData];
        if (shouldAutoScroll) {
            [_tableView ysf_scrollToBottom:YES];
        }
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapContent])
    {
        switch (message.messageType) {
            case YSF_NIMMessageTypeImage:
            {
                [self showImage:message touchView:event.data];
                handled = YES;
                break;
            }
            case YSF_NIMMessageTypeAudio:
            {
                [self onTapPlayAudio:event];
                handled = YES;
                break;
            }
            case YSF_NIMMessageTypeFile:
            {
                [self onTapFileMessage:message];
                handled = YES;
                break;
            }
            default:
                break;
        }
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapRichTextImage])
    {
        [self showImage:message touchView:event.data];
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapLabelPhoneNumber])
    {
        UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:event.data
                                                         message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil,nil];
        [dialog addButtonWithTitle:@"取消"];
        [dialog addButtonWithTitle:@"呼叫"];
        [dialog ysf_showWithCompletion:^(NSInteger index) {
            if (index == 1) {
                NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", event.data]];
                [[UIApplication sharedApplication] openURL:telURL];
            }
        }];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapMachineQuestion])
    {
        NSDictionary *questionDict = event.data;
        NSString *question = [questionDict objectForKey:YSFApiKeyQuestion];

        YSFServiceSession *session = [[QYSDK sharedSDK].sessionManager getOnlineSession:_shopId];
        if (session && !session.humanOrMachine) {
            NSNumber *questionId = [questionDict objectForKey:YSFApiKeyId];
            
            YSFReportQuestion *request = [[YSFReportQuestion alloc] init];
            request.command = YSFCommandReportQuestion;
            request.questionId = [questionId longLongValue];
            request.question = question;
            YSF_NIMMessage *questionMessage = [YSFMessageMaker msgWithCustom:request];
            [self sendMessage:questionMessage];
        }
        else {
            YSF_NIMMessage *message = [YSFMessageMaker msgWithText:question];
            [self sendMessage:message];
        }
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapEvaluationSelection])
    {
        BOOL yesOrNo = [event.data boolValue];
        YSFEvaluationAnswerRequest *answer = [YSFEvaluationAnswerRequest new];
        answer.evaluation = yesOrNo ? 2 : 3;
        answer.msgidClient = message.messageId;
        __weak typeof(self) weakSelf = self;
        [YSFIMCustomSystemMessageApi sendMessage:answer shopId:_shopId completion:^(NSError *error){
            if (!error) {
                YSF_NIMCustomObject *customObject = message.messageObject;
                YSFMachineResponse *response = (YSFMachineResponse*)customObject.attachment;
                response.evaluation = yesOrNo ? YSFEvaluationSelectionTypeYes : YSFEvaluationSelectionTypeNo;
                [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:weakSelf.session completion:nil];
            }
        }];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapEvaluationReason])
    {
        [self onTapEvaluationReasonWithMessage:message];
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapLabelLink])
    {
        NSString *url = event.data;
        //判断邮箱
        if ([url matchEmailFormat]) {
            [self popEmailActionSheetWithStr:url];
            handled = YES;
        }
        
        NSDictionary *dict = [url ysf_paramsFromString];
        [dict.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *commandStr = obj;
            if ([commandStr isEqualToString:@"applyHumanStaff"]) {
                [self onHumanChat:self.humanService];
                handled = YES;
            }
            else {
                NSAssert(NO, @"not support command");
            }
        }];
        if (handled == NO) {
            [self openUrl:url];
            handled = YES;
        }
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapKFBypass])
    {
        [self requestByBypassDict:event.message entryDict:event.data];
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapCommodityInfo]){
        YSF_NIMCustomObject *customObject = event.message.messageObject;
        QYCommodityInfo *commodityInfo = customObject.attachment;
        NSString *commodityUrl = commodityInfo.urlString;
        if (commodityUrl && ![commodityUrl isEqualToString:@""]) {
            [self openUrl:commodityUrl];
        }
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapEvaluation]){
        YSF_NIMCustomObject *customObject = event.message.messageObject;
        YSFInviteEvaluationObject *object = customObject.attachment;

        if (_onEvaluateBlock) {
            _onEvaluateBlock(object.sessionId, event.message);
        }
        else {
            [self showEvaluationViewController:event.message sessionId:object.sessionId evaluationData:object.evaluationDict
                    evaluationMessageThanks:object.evaluationMessageThanks];
        }

        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapGoods]){
        QYSelectedCommodityInfo *goods = event.data;
        YSFSelectedCommodityInfo *selectedGoods = [[YSFSelectedCommodityInfo alloc] init];
        selectedGoods.command = YSFCommandBotSend;
        selectedGoods.target = goods.target;
        selectedGoods.params = goods.params;
        selectedGoods.goods = goods;
        YSF_NIMMessage *selectedGoodsMessage = [YSFMessageMaker msgWithCustom:selectedGoods];
        [self sendMessage:selectedGoodsMessage];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapMoreOrders]){
        YSFOrderList *orderList = event.data;
        
        YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        vc.showTop = YES;
        vc.titleString = orderList.label;
        vc.action = orderList.action;
        vc.originalData = orderList.shops;

        __weak typeof(self) weakSelf = self;
        vc.tapItemCallback = ^(QYSelectedCommodityInfo *goods)
        {
            [weakSelf sendSelectedCommodityInfo:goods];
            
            return YES;
        };
        [self presentViewController:vc animated:YES completion:nil];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapMoreFlight]){
        YSFFlightList *flightList = event.data;
        [self popUpMoreListNav:flightList];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapBot]){
        [self onTapBotAction:event.data];

        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapPushMessageActionUrl]){
        [self onTapPushMessageActionUrl:event.data];
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameTapFillInBotForm]){
        long long sessionId = event.message.sessionIdFromMessageId;
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        YSFServiceSession *session = [sessionManager getOnlineSession:_shopId];
        if (session.sessionId == sessionId) {
            [self displayFillInBotForm:event.message];
        }
        else {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            [topmostWindow ysf_makeToast:@"该会话已结束，表单已失效" duration:2 position:YSFToastPositionCenter];
        }
        
        handled = YES;
    }
    else if ([eventName isEqualToString:YSFKitEventNameSendCommdityInfo]){
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        YSFServiceSession *session = [sessionManager getOnlineOrWaitingSession:_shopId];
        if (!session) {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            [topmostWindow ysf_makeToast:@"发送失败，会话已结束" duration:2 position:YSFToastPositionCenter];
        }
        else if (session && !session.humanOrMachine) {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            [topmostWindow ysf_makeToast:@"发送失败，机器人看不懂卡片哦 " duration:2 position:YSFToastPositionCenter];
        }
        else {
            YSF_NIMCustomObject *customObject = event.message.messageObject;
            QYCommodityInfo *show = (QYCommodityInfo *)(customObject.attachment);
            QYCommodityInfo *showCopy = [show copy];
            showCopy.sendByUser = NO;
            YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:showCopy];
            [self sendMessage:commodityInfoMessage];
        }

        handled = YES;
    }
    
    if (!handled) {
        //assert(0);
    }
}

- (void)requestByBypassDict:(YSF_NIMMessage *)message entryDict:(NSDictionary *)entryDict
{
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    [sessionManager clearByShopId:_shopId];
    [self clearSessionState];
    
    YSF_NIMCustomObject *customObject = message.messageObject;
    YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
    notification.disable = YES;
    [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:_session completion:nil];
    
    long long kfId = [(NSNumber *)[entryDict objectForKey:YSFApiKeyId] longLongValue];
    _entryId = [(NSNumber *)[entryDict objectForKey:YSFApiKeyEntryId] longLongValue];
    NSInteger type = [(NSNumber *)[entryDict objectForKey:YSFApiKeyType] integerValue];
    if (type == 1) {
        _groupId = kfId;
    }
    else if (type == 2) {
        _staffId = kfId;
    }
    [self requestServiceIfNeeded:NO onlyManual:YES];
}

- (void)popUpMoreListNav:(YSFFlightList *)flightList
{
    YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
    vc.showTop = NO;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (flightList.detail == nil) {
        vc.navigationItem.title = flightList.action.title;
        vc.action = flightList.action;
        vc.originalData = flightList.fieldItems;
    }
    else {
        vc.navigationItem.title = flightList.detail.label;
        vc.originalData = flightList.detail.flightDetailItems;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(nav) weakNav = nav;
    vc.tapItemCallback = ^(YSFAction *action)
    {
        if ([action.type isEqualToString:@"url"]
            || [action.type isEqualToString:@"block"]) {
            [weakSelf onTapBotAction:action];
        }
        else {
            YSFMoreOrderListViewController *vc2 = [YSFMoreOrderListViewController new];
            vc2.action = action;
            [weakNav pushViewController:vc2 animated:YES];
            return NO;
        }
        
        return YES;
        
    };
    
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                           style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTapBotAction:(YSFAction *)action
{
    if ([action.type isEqualToString:@"url"]) {
        QYBotClickBlock block = [QYCustomActionConfig sharedInstance].botClick;
        if (block) {
            block(action.target, action.params);
        }
    }
    else if ([action.type isEqualToString:@"float"]) {
        YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        vc.action = action;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if ([action.type isEqualToString:@"popup"]) {
        YSFFlightList *flightList = [YSFFlightList new];
        flightList.action = action;
        [self popUpMoreListNav:flightList];
    }
    else {
        YSFOrderOperation *orderOperation = [[YSFOrderOperation alloc] init];
        orderOperation.command = YSFCommandBotSend;
        orderOperation.target = action.target;
        orderOperation.params = action.params;
        orderOperation.template = @{@"id":@"qiyu_template_text", @"label":YSFStrParam(action.validOperation)};
        YSF_NIMMessage *orderOperationMessage = [YSFMessageMaker msgWithCustom:orderOperation];
        [self sendMessage:orderOperationMessage];
    }
}

- (void)onTapPushMessageActionUrl:(NSString *)actionUrl
{
    QYLinkClickBlock block = [QYCustomActionConfig sharedInstance].pushMessageClick;
    if (block) {
        block(actionUrl);
    }
}

- (void)displayFillInBotForm:(YSF_NIMMessage *)message
{
    [self.view endEditing:YES];
    [_sessionInputView removeKeyboardObserver];
    YSFBotFormViewController *vc = [YSFBotFormViewController new];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    YSF_NIMCustomObject *customObject = message.messageObject;
    YSFBotForm *botForm = customObject.attachment;
    vc.botForm = botForm;
    __weak typeof(self) weakSelf = self;
    vc.submitCallback = ^(BOOL submitted, YSFSubmittedBotForm *submittedBotForm)
    {
        [weakSelf.sessionInputView addKeyboardObserver];
        if (!submitted) {
            
            YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)message.messageObject;
            YSFBotForm *botForm = (YSFBotForm *)object.attachment;
            for (int i = 0; i < botForm.forms.count; i++) {
                ((YSFBotFormCell *)botForm.forms[i]).value = ((YSFSubmittedBotFormCell *)submittedBotForm.forms[i]).value;
                ((YSFBotFormCell *)botForm.forms[i]).imageValue = ((YSFSubmittedBotFormCell *)submittedBotForm.forms[i]).imageValue;
            }
            YSF_NIMCustomObject *customObject = [[YSF_NIMCustomObject alloc] init];
            customObject.attachment = botForm;
            message.messageObject = customObject;
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:weakSelf.session completion:nil];
            
            return;
        }
        long long sessionId = message.sessionIdFromMessageId;
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        YSFServiceSession *session = [sessionManager getOnlineSession:weakSelf.shopId];
        if (session.sessionId == sessionId) {
            NSString *tmpParams = [NSString stringWithFormat:@"msgIdClient=%@&", message.messageId];
            tmpParams = [tmpParams stringByAppendingString:botForm.params];
            tmpParams = [tmpParams stringByAppendingString:submittedBotForm.params];
            submittedBotForm.command = YSFCommandBotSend;
            submittedBotForm.params = tmpParams;
            YSF_NIMMessage *submittedBotFormMessage = [YSFMessageMaker msgWithCustom:submittedBotForm];
            [weakSelf sendMessage:submittedBotFormMessage];
            
            YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)message.messageObject;
            YSFBotForm *botForm = (YSFBotForm *)object.attachment;
            botForm.submitted = YES;
            YSF_NIMCustomObject *customObject = [[YSF_NIMCustomObject alloc] init];
            customObject.attachment = botForm;
            message.messageObject = customObject;
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:weakSelf.session completion:nil];
        }
        else {
            UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
            [topmostWindow ysf_makeToast:@"该会话已结束，表单已失效" duration:2 position:YSFToastPositionCenter];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(YSF_NIMMessageTypeImage) :    @"showImage:",
                    @(YSF_NIMMessageTypeAudio) :    @"playAudio:",
                    @(YSF_NIMMessageTypeVideo) :    @"showVideo:",
                    @(YSF_NIMMessageTypeLocation) : @"showLocation:",
                    @(YSF_NIMMessageTypeFile)  :    @"showFile:",
                    @(YSF_NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (void)openUrl:(NSString *)urlString
{
    QYLinkClickBlock clickBlock = [QYCustomActionConfig sharedInstance].linkClickBlock;
    if (clickBlock) {
        clickBlock(urlString);
    }
    else {
        UIImage *errorImage = [UIImage ysf_imageInKit:@"icon_loading"];
        YSFWebViewController *webViewController = [[YSFWebViewController alloc] initWithUrl:urlString errorImage:errorImage];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)showImage:(YSF_NIMMessage *)message touchView:(UIView *)touchView
{
    NSInteger imageViewIndex = touchView.tag;
    NSMutableArray *allGalleryItems = [NSMutableArray array];
    NSMutableArray *allLoadedImages = [self.sessionDatasource queryAllImageMessages];
    __block NSUInteger index = 0;
    __block NSUInteger currentIndex = 0;
    [allLoadedImages enumerateObjectsUsingBlock:^(YSF_NIMMessage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.messageType == YSF_NIMMessageTypeImage) {
            YSF_NIMImageObject *object = [obj messageObject];
            YSFGalleryItem *item = [[YSFGalleryItem alloc] init];
            item.thumbPath      = [object thumbPath];
            item.imageURL       = [object url];
            item.name           = [object displayName];
            item.message     = obj;
            item.indexAtMesaage = 0;
            [allGalleryItems addObject:item];
            if (message == obj) {
                index = currentIndex;
            }
            currentIndex++;
        }
        else {
            if (message == obj) {
                index = currentIndex + imageViewIndex;
            }
            YSF_NIMCustomObject *object = [obj messageObject];
            if ([object.attachment isKindOfClass:[YSFRichText class]]
                || [object.attachment isKindOfClass:[YSFMachineResponse class]]
                || [object.attachment isKindOfClass:[YSFStaticUnion class]]
                || [object.attachment isKindOfClass:[YSFSubmittedBotForm class]]) {
                id richText = object.attachment;
                
                [[richText imageUrlStringArray] enumerateObjectsUsingBlock:^(NSString * _Nonnull imageUrlString, NSUInteger idx, BOOL * _Nonnull stop) {
                    YSFGalleryItem *item = [[YSFGalleryItem alloc] init];
                    item.imageURL    = imageUrlString;
                    item.message     = obj;
                    item.indexAtMesaage = idx;
                    [allGalleryItems addObject:item];
                    currentIndex++;
                }];
                
            }
        }
        
    }];
    
    __weak typeof(self) weakSelf = self;
    YSFGalleryViewController *vc = [[YSFGalleryViewController alloc] initWithCurrentIndex:index allItems:allGalleryItems
                                                                                   callback:^(YSFGalleryItem *item) {
                                                                                       [weakSelf.tableView reloadData];
                                                                                       return [weakSelf onQueryMessageContentViewCallback:item];
                                                                                   }];
    [vc present:self touchView:touchView];
    
//    [self.navigationController pushViewController:vc animated:YES];
//    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
//        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
//        __weak typeof(self) wself = self;
//        [[YSF_NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
//            if (!error) {
//                [wself uiUpdateMessage:message];
//            }
//        }];
//    }
}

- (void)onTapPlayAudio:(YSFKitEvent *)event
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    BOOL isReceiverOrSpeaker = [infoManager isRecevierOrSpeaker];
    [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:isReceiverOrSpeaker ? YSF_NIMAudioOutputDeviceReceiver : YSF_NIMAudioOutputDeviceSpeaker];
    
    if (isReceiverOrSpeaker) {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentPlayingReceiver];
    }
}

- (void)onTapFileMessage:(YSF_NIMMessage *)message
{
    YSFFilePreviewViewController *vc = [[YSFFilePreviewViewController alloc] initWithFileMessage:message];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 点击填写差评原因
 */
- (void)onTapEvaluationReasonWithMessage:(YSF_NIMMessage*)message {
    [self.view endEditing:YES];
    [_sessionInputView removeKeyboardObserver];
    NSString *content;
    YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject*)message.messageObject;
    YSFMachineResponse *machineAttachment = (YSFMachineResponse*)customObject.attachment;
    if (!machineAttachment.evaluationContent || [machineAttachment.evaluationContent isEqualToString:@""]) {
        content = @"";
    } else {
        content = machineAttachment.evaluationContent;
    }
    __weak typeof(self) weakSelf = self;
    YSFEvaluationReasonView *evaluationResonView = [[YSFEvaluationReasonView alloc] initWithFrame:[UIScreen mainScreen].bounds content:content holdText:machineAttachment.evaluationGuide];
    evaluationResonView.delegate = self;
    evaluationResonView.data = message;
    evaluationResonView.completedBlock = ^{
        [weakSelf.sessionInputView inputBottomViewHeightToZero];
        [weakSelf.sessionInputView addKeyboardObserver];
    };
    [self.view.window addSubview:evaluationResonView];
    self.evaluationResonView = evaluationResonView;
}

//YSFEvaluationReasonViewDelegate
- (void)evaluationReasonView:(YSFEvaluationReasonView *)view didConfirmWithText:(NSString *)text {
    if (!text || !view.data) return;
    if ([[[QYSDK sharedSDK] sessionManager] getSessionStateType:_shopId] == YSFSessionStateTypeError) {
        [self.view ysf_makeToast:@"对话已结束，提交失败" duration:1 position:YSFToastPositionCenter];
        if (self.evaluationResonView) {
            [self.evaluationResonView removeFromSuperview];
            self.evaluationResonView = nil;
        }
        return;
    }
    YSF_NIMMessage *message = (YSF_NIMMessage*)view.data;
    YSFSetEvaluationReasonRequest *request = [YSFSetEvaluationReasonRequest new];
    request.msgId = message.messageId;
    request.evaluationContent = text;
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {
        if (!error) {
            if (self.evaluationResonView) {
                [self.evaluationResonView removeFromSuperview];
                self.evaluationResonView = nil;
            }
            YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject*)message.messageObject;
            YSFMachineResponse *machineAttachment = (YSFMachineResponse*)customObject.attachment;
            machineAttachment.evaluationContent = text;
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:weakSelf.session completion:nil];
            [self.view ysf_makeToast:@"感谢您的反馈" duration:1 position:YSFToastPositionCenter];
        } else {
            [self.view ysf_makeToast:@"提交失败，请稍后再试" duration:1 position:YSFToastPositionCenter];
        }
    }];
}


- (UIView *)onQueryMessageContentViewCallback:(YSFGalleryItem *)item
{
    NSArray *array = [self.tableView visibleCells];
    UIView *result = nil;
    for (UITableViewCell *cell in array)
    {
        if (![cell isKindOfClass:[YSFMessageCell class]])
        {
            continue;
        }
        YSFMessageCell *messageCell = (YSFMessageCell*)cell;
        if (messageCell.model.message != item.message) {
            continue;
        }
        
        if ([messageCell.bubbleView isKindOfClass:[YSFRichTextContentView class]]) {
            YSFRichTextContentView *contentView = (YSFRichTextContentView *)messageCell.bubbleView;
            if ( item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        }
        else if ([messageCell.bubbleView isKindOfClass:[YSFSessionMachineContentView class]]) {
            YSFSessionMachineContentView *contentView = (YSFSessionMachineContentView *)messageCell.bubbleView;
            if ( item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        }
        else if ([messageCell.bubbleView isKindOfClass:[YSFStaticUnionContentView class]]) {
            YSFStaticUnionContentView *contentView = (YSFStaticUnionContentView *)messageCell.bubbleView;
            if ( item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        }
        else {
            result = messageCell.bubbleView;
            break;
        }
    }
    
    return result;
}

- (void)onRetryMessage:(YSF_NIMMessage *)message
{
    if (message.isReceivedMsg) {
        [[[YSF_NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                           error:nil];
    }
    else {
        [self uiDeleteMessage:message];
        if (message.messageType == YSF_NIMMessageTypeAudio) {
            [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:message];
            YSF_NIMAudioObject *audioObject =  (YSF_NIMAudioObject *)message.messageObject;
            [self sendAudio:audioObject.path];
        }
        else {
            [[[YSF_NIMSDK sharedSDK] chatManager] resendMessage:message
                                                          error:nil];
        }
    }
}

#pragma mark - 菜单
- (void)onLongPressCell:(YSF_NIMMessage *)message
                 inView:(UIView *)view
{
    NSArray *items = [self menusItems:message];
    if ([items count]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        
        if ([self.sessionInputView.toolBar.inputTextView isFirstResponder]) {
            self.sessionInputView.toolBar.inputTextView.overrideNextResponder = self;
        }
        else {
            [self becomeFirstResponder];
        }
        
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)menusItems:(YSF_NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    if (message.messageType == YSF_NIMMessageTypeAudio) {
        NSString *string;
        if ([[QYSDK sharedSDK].infoManager isRecevierOrSpeaker]) {
            string = @"扬声器模式";
        } else {
            string = @"听筒模式";
        }
        [items addObject:[[UIMenuItem alloc] initWithTitle:string
                                                    action:@selector(changePlayAudioMode:)]];
        
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字"
                                                    action:@selector(transAudioToText:)]];
    } else if (message.messageType == YSF_NIMMessageTypeText && message.text.length > 0) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyTextOrImage:)]];
    } else if (message.messageType == YSF_NIMMessageTypeImage) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyTextOrImage:)]];
    } else if (message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]
            || [customObject.attachment isKindOfClass:[QYCommodityInfo class]]) {
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                        action:@selector(copyTextOrImage:)]];
            
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                        action:@selector(deleteMsg:)]];
        }
    } else {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                    action:@selector(deleteMsg:)]];
    }
    
    return items;
}

- (YSF_NIMMessage *)messageForMenu
{
    return _messageForMenu;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)changePlayAudioMode:(id)sender
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    BOOL isReceiverOrSpeaker = [infoManager isRecevierOrSpeaker];
    [infoManager setRecevierOrSpeaker:!isReceiverOrSpeaker];
    if (isReceiverOrSpeaker) {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentModeSpeaker];
    }
    else {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentModeReceiver];
    }
}

- (void)transAudioToText:(id)sender
{
    YSF_NIMMessage *message = [self messageForMenu];
    if (message.messageType == YSF_NIMMessageTypeAudio) {
        YSF_NIMAudioObject *audioObject =  (YSF_NIMAudioObject *)message.messageObject;
        YSF_NIMAudioToTextOption *option = [YSF_NIMAudioToTextOption new];
        option.url = audioObject.url;
        option.filepath = audioObject.path;
        YSFTransAudioToTextLoadingViewController *vc = [[YSFTransAudioToTextLoadingViewController alloc] initWithAudioToTextOption:message];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        //assert(false);
    }
}

#pragma mark - 音频输出设备变化
- (void)onAVSessionChanged:(NSNotification*)notification
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![[YSF_NIMSDK sharedSDK].mediaManager isPlaying]) {
            return;
        }
        
        AVAudioSessionRouteDescription *previousRouteDescription = [notification userInfo][AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *previousPortDescription= [previousRouteDescription.outputs firstObject];
        AVAudioSessionRouteDescription *currentRouteDescription = [[AVAudioSession sharedInstance] currentRoute];
        AVAudioSessionPortDescription *currentPortDescription= [currentRouteDescription.outputs firstObject];
        if ([previousPortDescription.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]
            && [currentPortDescription.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            [weakSelf.recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentPlayingSpeaker];
        }
    });
}

- (void)copyTextOrImage:(id)sender
{
    YSF_NIMMessage *message = [self messageForMenu];
    if (message.messageType == YSF_NIMMessageTypeText) {
        if (message.text.length) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(message.text)];
        }
    }
    else if (message.messageType == YSF_NIMMessageTypeImage) {
        YSF_NIMImageObject *imageObject = (YSF_NIMImageObject *)message.messageObject;
        if (imageObject.thumbPath.length) {
            UIImage * image = [UIImage imageWithContentsOfFile:imageObject.thumbPath];
            if (image) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setImage:image];
            }
        }
    }
    else if (message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFMachineResponse class]]) {
            YSFMachineResponse *machineResponse = (YSFMachineResponse *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(machineResponse.rawStringForCopy)];
        }
        else if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
            YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(notification.rawStringForCopy)];
        }
        else if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]) {
            YSFReportQuestion *notification = (YSFReportQuestion *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(notification.question)];
        }
        else if ([customObject.attachment isKindOfClass:[QYCommodityInfo class]]){
            QYCommodityInfo *commodityInfoShow = (QYCommodityInfo *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(commodityInfoShow.urlString)];
        }
    }
}

- (void)deleteMsg:(id)sender
{
    YSF_NIMMessage *message    = [self messageForMenu];
    YSFMessageModel *model = [self makeModel:message];
    [self.layoutManager deleteCellAtIndexs:[self.sessionDatasource deleteMessageModel:model]];
    [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:model.message];
    if (message.messageType == YSF_NIMMessageTypeFile) {    //文件消息删除的同时文件缓存也要删除
        YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)message.messageObject;
        [[NSFileManager defaultManager] removeItemAtPath:fileObject.path error:nil];
    }
}


#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages{
    NSArray *insert = [self.sessionDatasource addMessages:messages];
    for (YSF_NIMMessage *message in messages) {
        YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
        [self layoutConfig:model];
    }
    [self.layoutManager insertTableViewCellAtRows:insert scrollToBottom:YES];
    
    return;
}

- (void)uiDeleteMessage:(YSF_NIMMessage *)message{
    YSFMessageModel *model = [self makeModel:message];
    NSArray *indexs = [self.sessionDatasource deleteMessageModel:model];
    [self.layoutManager deleteCellAtIndexs:indexs];
}

- (void)uiUpdateMessage:(YSF_NIMMessage *)message
{
    YSFMessageModel *model = [self makeModel:message];
    NSInteger index = [self.sessionDatasource indexAtModelArray:model];
    if (index > -1) {
        [model cleanLayoutConfig];
        [model cleanCache];
        model = [self makeModel:message];
        [self.sessionDatasource.modelArray replaceObjectAtIndex:index withObject:model];
        [self.layoutManager updateCellAtIndex:index model:model];

        BOOL shouldAutoScroll = (index == [self.sessionDatasource msgCount] - 1) && [_tableView ysf_isInBottom];
        [_tableView reloadData];
        if (shouldAutoScroll) {
            [_tableView ysf_scrollToBottom:YES];
        }
    }
}


#pragma mark - 客服相关的接口
- (BOOL)requestServiceIfNeeded:(BOOL)isInit onlyManual:(BOOL)onlyManual
{
    if ([self isLastMessageKFBypassNotificationAndEnable]) {
        return NO;
    }
    
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    sessionManager.delegate = self;
    
    if ([sessionManager shouldRequestService:isInit shopId:_shopId])
    {
        [[YSFSearchQuestionSetting sharedInstance:_shopId] clear];
        self.hasRequested = YES;
        _evaluation.enabled = NO;
        if (_changeEvaluationEnabledBlock) {
            _changeEvaluationEnabledBlock(NO);
        }
        _evaluationText.enabled = NO;
        YSFRequestServiceRequest *request = [[YSFRequestServiceRequest alloc] init];
        request.source = _source;
        request.onlyManual = onlyManual;
        request.groupId = _groupId;
        request.staffId = _staffId;
        request.robotId = _robotId;
        request.vipLevel = _vipLevel;
        request.entryId = _entryId;
        request.commonQuestionTemplateId = _commonQuestionTemplateId;
        request.openRobotInShuntMode = _openRobotInShuntMode;
        [sessionManager requestServicewithSource:request shopId:_shopId];
        if ([sessionManager getSessionStateType:_shopId] == YSFSessionStateTypeNotExist) {
            return YES;
        }
        else {
            return NO;
        }
        
    }
    return YES;
}

#pragma mark - 商品信息展示发送请求
//只有收到欢迎服务用语后才会发送一次
- (void)sendCommodityInfoRequest:(BOOL)bAuto
{
    if (_commodityInfo) {
        [_commodityInfo checkCommodityInfoValid];
        QYCommodityInfo *commodityInfoShow = [_commodityInfo copy];
        commodityInfoShow.bAuto = bAuto;
        
        if (_commodityInfo.sendByUser) {
            YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:commodityInfoShow];
            commodityInfoMessage.session = _session;
            commodityInfoMessage.from = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
            commodityInfoMessage.isDeliveried = YES;
            [self onAddMessage:commodityInfoMessage];
        }
        else {
            if (!_commodityInfo.show) {
                YSFSetCommodityInfoRequest *request = [[YSFSetCommodityInfoRequest alloc] init];
                request.commodityInfo = [commodityInfoShow encodeAttachment];
                [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:nil];
            }
            else{
                YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:commodityInfoShow];
                [self sendMessage:commodityInfoMessage];
            }
        }
        g_commodityInfo = _commodityInfo;
    }
}

#pragma mark - YSFSessionProtocol
- (void)didBeginSendReqeustWithShopId:(NSString *)shopId
{
    //shopId存在nil的可能，所以进行放行并提示
    if (shopId && ![_shopId isEqualToString:shopId]) return;
    
    self.navigationItem.title = @"正在连接客服";
    [_tipView setSessionTip:YSFSessionTipOK];
}

- (void)didSendSessionRequest:(NSError *)error shopId:(NSString *)shopId
{
    if (![_shopId isEqualToString:shopId]) return;
    
    if (error && error.code != YSF_NIMLocalErrorCodeUserInfoNeeded)
    {
        self.navigationItem.title = [self sessionTitle];
        [_tipView setSessionTip:YSFSessionTipRequestServiceFailed];
        
        [self resetKFBypassNotificationStatus];
    }
}

- (void)didReceiveSessionError:(NSError *)error
                    session:(YSFServiceSession *)session shopId:(NSString *)shopId
{
    if (![_shopId isEqualToString:shopId]) return;
    
    [self.tableView reloadData];
    self.navigationItem.title = [self sessionTitle];
    
    if (error == nil)
    {
        [_tipView setSessionTip:YSFSessionTipOK];
        if (session) {
            [self changeHumanOrMachineState:(session.humanOrMachine) operatorEable:session.operatorEable];
        }
        
        if (!session) {
            [self initRightCustomButtonStatus];
        }
        else if (session.humanOrMachine) {
            BOOL needSave = YES;
            NSDictionary *currentDict = [[[QYSDK sharedSDK] sessionManager] getEvaluationInfoByShopId:_shopId];
            if (currentDict) {
                NSNumber *currentSessionId = [currentDict objectForKey:YSFCurrentSessionId];
                if ([currentSessionId longLongValue] == session.sessionId) {
                    needSave = NO;
                    NSString *sessionTimes = [currentDict objectForKey:YSFSessionTimes];
                    if ([sessionTimes intValue] == -1) {
                        [self changeEvaluationButtonToDone];
                    }
                    else {
                        [self changeEvaluationButtonToEnable];
                    }
                }
            }
            
            if (needSave) {
                [self changeEvaluationButtonToEnable];
            }
        }
        
        if (session.humanOrMachine) {
            [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
        }
        else {
            [_sessionInputView setActionInfoArray:session.actionInfoArray];
        }
    }
    else
    {
        if ([error code] == YSFCodeServiceNotExist)
        {
            [self changeToNotExsitState:session];
            [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
        }
        else if ([error code] == YSFCodeServiceNotExistAndLeaveMessageClosed)
        {
            [self changeToNotExsitAndLeaveMessageClosedState:session];
        }
        else if ([error code] == YSFCodeServiceWaiting)
        {
            [self changeToWaitingState:session.robotInQueue];
            [self queryWaitingStatus:shopId];
            [_tipView setSessionTipForWaiting:session.showNumber waitingNumber:session.before inQueeuStr:session.inQueeuNotify];
        }
        else
        {
            [_tipView setSessionTip:YSFSessionTipRequestServiceFailed];
        }
    }
}

- (void)didReceiveWaitingStatus:(NSError *)error waitStatus:(YSFQueryWaitingStatusResponse *)waitStatus shopId:(NSString *)shopId
{
    if (![_shopId isEqualToString:shopId]) return;
    
    if (error == nil) {
        [_tipView setSessionTipForWaiting:waitStatus.showNumber waitingNumber:waitStatus.waitingNumber
                               inQueeuStr:waitStatus.inQueeuNotify];
    }
    else {
        //目前不需要处理
    }
}

- (void)clearSessionState
{
    if (!_specifiedId) {
        _groupId = 0;
        _staffId = 0;
    }
    _entryId = 0;
}

- (void)didClose:(BOOL)evaluate session:(YSFServiceSession *)session shopId:(NSString *)shopId
{
    if (![_shopId isEqualToString:shopId]) return;
    
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    if ([sessionManager getOnlineSession:_shopId] && [sessionManager getOnlineSession:_shopId].sessionId == session.sessionId) {
        [self clearSessionState];
        _closeSession.enabled = NO;
        _closeSessionText.enabled = NO;
        
        if (_evaluation.enabled == YES) {
            if (!self.presentedViewController) {
                if (!evaluate) {
                    [_evaluation animation_shakeImageWithDuration];
                    _currentInviteEvaluationMessage = nil;
                }
            }
        }
    }
    
    [_sessionInputView setActionInfoArray:nil];
}

- (void)onHumanChat:(id)sender
{
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    [sessionManager clearByShopId:_shopId];
    [self clearSessionState];
    [self requestServiceIfNeeded:NO onlyManual:YES];
}

- (void)queryWaitingStatus:(NSString *)shopId
{
    [_queryWaitingStatusTimer start:dispatch_get_main_queue() interval:10 repeats:NO block:^{
        YSFQueryWaitingStatusRequest *request = [[YSFQueryWaitingStatusRequest alloc] init];
        
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:shopId completion:^(NSError *error) {}];
    }];
}

- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@",content);
    
    //平台电商时sender就等于shopId，目前服务器这样处理
    NSString *shopId = notification.sender;
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    
    id object =  [YSFCustomSystemNotificationParser parse:content shopId:shopId];
    if ([object isKindOfClass:[YSFQueryWaitingStatusResponse class]])
    {
        YSFQueryWaitingStatusResponse *wait_status = object;
        NSError *error = wait_status.code == YSFCodeSuccess ? nil : [NSError errorWithDomain:YSFErrorDomain
                                                                                        code:wait_status.code
                                                                                    userInfo:nil];
        [self didReceiveWaitingStatus:error waitStatus:wait_status shopId:shopId];
        if (wait_status.code != YSFCodeSuccess) {
            [_queryWaitingStatusTimer stop];
        }
        else {
            [self queryWaitingStatus:shopId];
        }
    }
    else if ([object isKindOfClass:[YSFSendSearchQuestionResponse class]])
    {
        if (_sessionInputView.toolBar.inputTextView.text.length == 0) {
            return;
        }
        YSFSendSearchQuestionResponse *sendSearchQuestionResponse = (YSFSendSearchQuestionResponse *)object;

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:sendSearchQuestionResponse.questionContents.count];
        _quickReplyView.searchText = sendSearchQuestionResponse.content;
        for (YSFQuickReplyKeyWordAndContent *content in sendSearchQuestionResponse.questionContents) {
            content.content = content.content;
            content.isContentRich = NO;
            [array addObject:content];
        }

        [self.quickReplyView updateDataArray:array];
        [self.quickReplyView removeFromSuperview];
        if (self.quickReplyView.itemCount) {
            //动态改变高度
            if (self.quickReplyView.itemCount > 2) {
                self.quickReplyView.ysf_frameHeight = 121;
            } else {
                self.quickReplyView.ysf_frameHeight = self.quickReplyView.viewHeight;
            }
            [self.view addSubview:self.quickReplyView];
        }
    }
    else if ([object isKindOfClass:[YSFBotEntry class]])
    {
        [_sessionInputView setActionInfoArray:((YSFBotEntry *)object).entryArray];
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        if (sessionManager) {
            [sessionManager getOnlineSession:_shopId].actionInfoArray = ((YSFBotEntry *)object).entryArray;
        }
    }
}

#pragma mark - 网络变化
- (void)onNetworkChanged:(id)sender
{
    BOOL reachable = [_reachability isReachable];
    [_tipView setSessionTip:reachable ? YSFSessionTipNetworkOK : YSFSessionTipNetworkError];
}

#pragma mark - TipViewDelegate
- (void)tipViewRequestService:(YSFSessionTipView *)tipView
{
    [self requestServiceIfNeeded:NO onlyManual:NO];
}

- (void)quitWaiting:(YSFSessionTipView *)tipView
{
    __weak typeof(self) weakSelf = self;
    [self onCloseSessionWith:NO showQuitWaitingBlock:^(QuitWaitingType quitType) {
        if (quitType == QuitWaitingTypeQuit) {
            [weakSelf.queryWaitingStatusTimer stop];
            [weakSelf.tipView setSessionTip:YSFSessionTipOK];
            YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
            [sessionManager clearByShopId:weakSelf.shopId];
            
            [self clearSessionState];
            weakSelf.closeSession.enabled = NO;
            weakSelf.closeSessionText.enabled = NO;
        }
    }];
}

#pragma mark - 旋转处理 (iOS7)
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self.sessionDatasource cleanCache];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
    [_sessionInputView setRecordPhase:AudioRecordPhaseCancelling];
    [_sessionInputView setRecordPhase:AudioRecordPhaseEnd];
}

- (BOOL)requestServiceWithTip
{
    BOOL shouldSend = ![self isLastMessageKFBypassNotificationAndEnable];
    if (!shouldSend) {
        UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
        [topmostWindow ysf_makeToast:@"为了给您提供更专业的服务，请您选择要咨询的内容类型" duration:2.0 position:YSFToastPositionCenter];
        return NO;
    }
    
    shouldSend = [self requestServiceIfNeeded:NO onlyManual:NO];
    if (!shouldSend) {
        UIWindow *topmostWindow = [[[UIApplication sharedApplication] windows] lastObject];
        [topmostWindow ysf_makeToast:@"请等待连接客服成功后，再发送消息" duration:2.0 position:YSFToastPositionCenter];
    }
    return shouldSend;
}

#pragma mark - 相册
- (void)OnMediaPicturePressed
{
    BOOL shouldSend = [self requestServiceWithTip];
    if (!shouldSend) {
        return;
    }
    
    [self.sessionInputView.toolBar.inputTextView resignFirstResponder];
    [self showSelectImageAlertController];
}

#pragma mark - 发送邮件
- (void)popEmailActionSheetWithStr:(NSString*)str{
    
    _emailStr = str;
    __weak typeof(self) weakSelf = self;
    YSFAlertController *controller = [YSFAlertController actionSheetWithTitle:[NSString stringWithFormat:@"向%@发送邮件",str]];
    [controller addAction:[YSFAlertAction actionWithTitle:@"使用默认邮件账户" style:YSFAlertActionStyleDefault handler:^(YSFAlertAction * _Nonnull action) {
       
        if (weakSelf.emailStr != nil && weakSelf.emailStr.length > 0) {
            NSString* openStr = [NSString stringWithFormat:@"mailto:%@", weakSelf.emailStr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openStr]];
        }

    }]];

    [controller addCancelActionWithHandler:nil];
    [controller showWithSender:nil arrowDirection:UIPopoverArrowDirectionAny controller:self animated:YES completion:nil];
}

- (void)showSelectImageAlertController
{
    __weak typeof(self) weakSelf = self;
    YSFAlertController * alertController = [YSFAlertController actionSheetWithTitle:nil];
    [alertController addAction:[YSFAlertAction actionWithTitle:@"选择本地图片" handler:^(YSFAlertAction * _Nonnull action) {
        //相册
        [weakSelf mediaPicturePressed];
    }]];
    
    [alertController addAction:[YSFAlertAction actionWithTitle:@"拍照" handler:^(YSFAlertAction * _Nonnull action) {
        //拍照
        [weakSelf mediaShootPressed];
    }]];
    
    [alertController addCancelActionWithHandler:nil];
    
    [alertController showWithSender:_sessionInputView.toolBar.imageButton
                     arrowDirection:UIPopoverArrowDirectionAny controller:self animated:YES completion:nil];
}

- (void)mediaPicturePressed
{
    self.mode = YSFImagePickerModePicture;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (UIImagePickerController *)cameraInit
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"检测不到相机设备"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return nil;
    }
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:@"没有相机权限"
                                    message:@"请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机。"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return nil;
        
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    return imagePicker;
}

- (void)mediaShootPressed
{
    UIImagePickerController *imagePicker = [self cameraInit];
    if (imagePicker) {
        self.mode = YSFImagePickerModeShoot;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)onPasteImage:(UIImage *)image
{
    YSFImageConfirmedViewController *vc = [[YSFImageConfirmedViewController alloc] initWithImage:image];
    __weak typeof(self) weakSelf = self;
    vc.sendingImageConfirmedCallback = ^(BOOL shouldSend) {
        if (shouldSend) {
            [weakSelf sendMessage:[YSFMessageMaker msgWithImage:image]];
        }
    };
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
    [self.sessionInputView.toolBar.inputTextView resignFirstResponder];
}

#pragma mark - ImagePicker初始化
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {

    }
    else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        __weak typeof(self) weakSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{

            switch (weakSelf.mode) {
                case YSFImagePickerModePicture:
                {
                    [weakSelf sendMessage:[YSFMessageMaker msgWithImage:orgImage]];
                    break;
                }
                case YSFImagePickerModeShoot:
                {
                    UIImageWriteToSavedPhotosAlbum(orgImage, nil, nil, nil);
                    [weakSelf sendMessage:[YSFMessageMaker msgWithImage:orgImage]];
                    break;
                }
                default:
                    break;
            }
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma QYSessionDelegate
- (void)pickImageCompeletedWithImages:(NSArray*)images {
    
    for (UIImage* image in images) {
        [self sendMessage:[YSFMessageMaker msgWithImage:image]];
    }
    
}
- (void)pickImageCanceled
{
    
}

- (void)sendEvaluationRequest:(long long)sessionId score:(NSUInteger)score remarks:(NSString *)remarks
                       tagIds:(NSArray<YSFKaolaTagInfo *> *)tagInfos callback:(void (^)(NSError *error))callback
{
    YSFEvaluationRequest *request = [[YSFEvaluationRequest alloc] init];
    request.score = score;
    request.remarks = remarks;
    request.tagInfos = tagInfos;
    request.sessionId = sessionId;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)setButtonInfoArray:(NSArray<QYButtonInfo *> *)buttonInfoArray
{
    _ysfActionInfoArray = [NSMutableArray<YSFActionInfo *> new];
    for (QYButtonInfo *info in buttonInfoArray) {
        YSFActionInfo *ysfActionInfo = [YSFActionInfo new];
        ysfActionInfo.action = QYActionTypeOpenUrl;
        ysfActionInfo.buttonId = info.buttonId;
        ysfActionInfo.title = info.title;
        ysfActionInfo.userData = info.userData;
        
        [_ysfActionInfoArray addObject:ysfActionInfo];
    }
}

- (void)sendCommodityInfo:(QYCommodityInfo *)commodityInfo
{
    self.commodityInfo = commodityInfo;
    g_commodityInfo = _commodityInfo;
    [self sendCommodityInfoRequest:NO];
}

- (void)sendSelectedCommodityInfo:(QYSelectedCommodityInfo *)commodityInfo
{
    YSFSelectedCommodityInfo *selectedGoods = [[YSFSelectedCommodityInfo alloc] init];
    selectedGoods.command = YSFCommandBotSend;
    selectedGoods.target = commodityInfo.target;
    selectedGoods.params = commodityInfo.params;
    selectedGoods.goods = commodityInfo;
    YSF_NIMMessage *selectedGoodsMessage = [YSFMessageMaker msgWithCustom:selectedGoods];
    [self sendMessage:selectedGoodsMessage];
}

- (void)sendPicture:(UIImage *)picture
{
    [self sendMessage:[YSFMessageMaker msgWithImage:picture]];
}

@end

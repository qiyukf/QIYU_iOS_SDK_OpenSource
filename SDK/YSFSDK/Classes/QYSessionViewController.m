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
#import "YSFBotCustomObject.h"
#import "YSFBotEntry.h"
#import "QYCommodityInfo_private.h"
#import "QYStaffInfo.h"
#import "QYAction.h"
#import "YSFRevokeMessageResult.h"
#import "YSFEvaluationResult.h"

#import "YSFViewControllerTransitionAnimation.h"
#import "YSFCameraViewController.h"
#import "YSFVideoPlayerViewController.h"
#import "YSFVideoDataManager.h"

@import MobileCoreServices;
@import AVFoundation;


typedef NS_ENUM(NSUInteger, YSFImagePickerMode) {
    YSFImagePickerModePicture,
    YSFImagePickerModeShoot,
    YSFImagePickerModeVideo,
};

YSFInputStatus g_inputStatus = YSFInputStatusText;
QYCommodityInfo *g_commodityInfo = nil;
int64_t g_commonQuestionTemplateId = 0;
static long long g_sessionId;


@implementation YSFKaolaTagInfo
@end

@interface QYButtonInfo()

@property (nonatomic, assign) NSUInteger actionType;
@property (nonatomic, assign) NSUInteger index;

@end

@implementation QYButtonInfo
@end

@interface QYSessionViewController()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate,
YSF_NIMSystemNotificationManagerDelegate, YSFAppInfoManagerDelegate, YSFEvaluationReasonViewDelegate, YSFQuickReplyContentViewDelegate,
YSFCameraViewControllerDelegate>

@property (nonatomic, weak) id<QYSessionViewDelegate> delegate;  //会话窗口回调

@property (nonatomic, strong) UIButton *humanService;
@property (nonatomic, strong) UIButton *humanServiceText;
@property (nonatomic, strong) UIButton *shopEntrance;
@property (nonatomic, strong) UIButton *shopEntranceText;
@property (nonatomic, strong) UIButton *evaluation;
@property (nonatomic, strong) UIButton *evaluationText;
@property (nonatomic, strong) UIButton *closeSession;
@property (nonatomic, strong) UIButton *closeSessionText;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *moreButtonText;
@property (nonatomic, strong) UIImageView *sessionListImageView;
@property (nonatomic, strong) UIButton *sessionListButton;
@property (nonatomic, strong) YSFPopTipView *popTipView;
@property (nonatomic, strong) YSFQuickReplyContentView *quickReplyView;

@property (nonatomic, copy) NSString *shopId;  //平台电商店铺Id，非平台电商为-1
@property (nonatomic, assign) int64_t entryId;
@property (nonatomic, copy) NSString *emailStr;
@property (nonatomic, strong) YSF_NIMMessage *currentInviteEvaluationMessage;
@property (nonatomic, copy) NSString *lastMessageContent;
@property (nonatomic, strong) NSMutableArray<YSFActionInfo *> *ysfActionInfoArray;
@property (nonatomic, strong) YSFTimer *queryWaitingStatusTimer;
@property (nonatomic, strong) YSFTimer *inputtingMessageTimer;
@property (nonatomic, strong) YSFTimer *inputAssociateTimer;
@property (nonatomic, assign) YSFImagePickerMode mode;

@property (nonatomic, assign) QYRequestStaffBeforeScene requestScene;
@property (nonatomic, assign) BOOL hasRequested;
@property (nonatomic, assign) BOOL onlyManual;
@property (nonatomic, copy) QYCompletion changeStaffCompletion;

@property (nonatomic, assign) BOOL needShowHistoryTip;

@end


@implementation QYSessionViewController

#pragma mark - Setter
- (void)setShopId:(NSString *)shopId {
    _shopId = [shopId lowercaseString];
}

- (void)setStaffInfo:(QYStaffInfo *)staffInfo {
    _staffInfo = staffInfo;
    [[QYSDK sharedSDK] sessionManager].staffInfo = staffInfo;
}

- (void)setButtonInfoArray:(NSArray<QYButtonInfo *> *)buttonInfoArray {
    _ysfActionInfoArray = [NSMutableArray<YSFActionInfo *> new];
    for (QYButtonInfo *info in buttonInfoArray) {
        YSFActionInfo *ysfActionInfo = [YSFActionInfo new];
        ysfActionInfo.action = YSFActionTypeOpenUrl;
        ysfActionInfo.buttonId = info.buttonId;
        ysfActionInfo.title = info.title;
        ysfActionInfo.userData = info.userData;
        [_ysfActionInfoArray addObject:ysfActionInfo];
    }
}

#pragma mark - Dealloc
-(void)dealloc {
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
    [QYCustomUIConfig sharedInstance].humanButtonText = nil;
    [QYCustomActionConfig sharedInstance].actionBlock = nil;
}

#pragma mark - Init
- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if ([[QYSDK sharedSDK] infoManager].accountInfo.bid) {
            _shopId = [[QYSDK sharedSDK] infoManager].accountInfo.bid;
        }
        _reachability = [YSFReachability reachabilityForInternetConnection];
        _hasRequested = NO;
        _openRobotInShuntMode = NO;
        _messagePageLimit = 20;
        _hideHistoryMessages = NO;
        _historyMessagesTip = @"以上是历史消息";
        _queryWaitingStatusTimer = [[YSFTimer alloc]init];
        _inputtingMessageTimer = [[YSFTimer alloc]init];
        _inputAssociateTimer = [[YSFTimer alloc] init];
        _requestScene = QYRequestStaffBeforeSceneNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSession];
    
    if (!self.staffInfo) {
        [[QYSDK sharedSDK] sessionManager].staffInfo = nil;
    }
    //若当前会话有未读消息，则不收起历史消息
    if ([[[YSF_NIMSDK sharedSDK] conversationManager] unreadCountInSession:_session]) {
        self.hideHistoryMessages = NO;
    }
    
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
            [weakSelf sendCloseSessionCustomMessage:YES quitSessionViewController:YES showQuitWaitingBlock:showQuitWaitingBlock];
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
    //若最后一条消息是邀请评价消息，则记录该条消息
    YSF_NIMMessage *lastMessage = [self getLastMessage];
    if (lastMessage && lastMessage.messageType == YSF_NIMMessageTypeCustom) {
        id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)lastMessage.messageObject attachment];
        if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]]) {
            _currentInviteEvaluationMessage = lastMessage;
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
    //若有未读消息，则不请求新会话
    //若保存的评价数据中session_status为2，说明是人工客服且未评价过；此时将右上角评价按钮更新为可点击状态
    NSInteger count = [[[YSF_NIMSDK sharedSDK] conversationManager] unreadCountInSession:_session];
    if (count > 0) {
        shouldRequestService = NO;
        [[[QYSDK sharedSDK] sessionManager] updateStaffInfoForOnlineSession:_shopId];
        NSDictionary *dict = [sessionManager getRecentEvaluationMemoryDataByShopId:_shopId];
        NSInteger status = [[dict objectForKey:YSFEvaluationSessionStatus] integerValue];
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
    
    //进入会话界面时会话未结束，此时若设置了首问卡片，则需要主动发送
    if ([sessionManager getOnlineSession:_shopId]) {
        if ([sessionManager getOnlineSession:_shopId].humanOrMachine) {
            //人工模式下，始终支持首问卡片发送
            if (_commodityInfo && (![g_commodityInfo isEqual:_commodityInfo] || _commodityInfo.sendByUser)) {
                [self sendCommodityInfoRequest:YES];
            }
        } else {
            //机器人模式下，若开启了autoSendInRobot则支持首问卡片发送
            if (self.autoSendInRobot) {
                if (_commodityInfo && (![g_commodityInfo isEqual:_commodityInfo] || _commodityInfo.sendByUser)) {
                    [self sendCommodityInfoRequest:YES];
                }
            }
        }
    }
    
    if (shouldRequestService) {
        [[[QYSDK sharedSDK] sessionManager] updateStaffInfoForOnlineSession:_shopId];
        [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneInit onlyManual:NO clearSession:NO];
    } else {
        [self throwRequestStaffAfterBlock];
    }
    
    [[[YSF_NIMSDK sharedSDK] conversationManager] markAllMessageReadInSession:_session];
    [sessionManager reportPushMessageReadedStatus];
    
    NSString *text = [[[QYSDK sharedSDK] infoManager] cachedText:_shopId];
    [self.sessionInputView setInputText:text];
    //判断是否需要自动弹出评价VC，若需要弹出，则不弹出键盘
    BOOL autoPopUp = [self popEvaluationViewControllerIfNeeded];
    if (!autoPopUp && [QYCustomUIConfig sharedInstance].autoShowKeyboard && g_inputStatus != YSFInputStatusAudio) {
        [self.sessionInputView.toolBar.inputTextView becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    YSFLogApp(@"");
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    YSFLogApp(@"");
    [super viewDidAppear:animated];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
        [self.view setNeedsLayout];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    YSFLogApp(@"");
    [super viewWillDisappear:animated];
    [[YSF_NIMSDK sharedSDK].mediaManager cancelRecord];
    [[YSF_NIMSDK sharedSDK].mediaManager stopPlay];
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

- (void)viewDidLayoutSubviews {
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
    _tipView.ysf_frameLeft = _tableView.ysf_frameLeft;
    if (self.navigationController.navigationBar.translucent) {
        _tipView.ysf_frameTop = self.navigationController.navigationBar.ysf_frameBottom;
    } else {
        _tipView.ysf_frameTop = 0;
    }
    _tipView.ysf_frameWidth = _tableView.ysf_frameWidth;
    _tipView.ysf_frameHeight = [_tipView getTipLabelHeight] + 18;
    UIEdgeInsets contentInset = _tableView.contentInset;
    if (_tipView.hidden) {
        contentInset.top = _tipView.ysf_frameTop;
    } else {
        contentInset.top = _tipView.ysf_frameBottom;
    }
    
    contentInset.bottom = 0;
    _tableView.contentInset = contentInset;
    _tableView.scrollIndicatorInsets = contentInset;
    _recordTipView.frame = _tipView.frame;
    [self setSessionListEntranceFrame];
    
    if (isFirstLayout) {
        CGFloat safeAreaBottom = 0;
        if (@available(iOS 11, *)) {
            safeAreaBottom = self.view.safeAreaInsets.bottom;
        }
        _tableView.ysf_frameHeight -= safeAreaBottom;
        
        for (id model in [_sessionDataSource modelArray]) {
            if ([model isKindOfClass:[YSFMessageModel class]]) {
                [(YSFMessageModel *)model cleanCache];
            }
        }
        [_tableView reloadData];
        [_tableView ysf_scrollToBottom:YES];
    }
}

- (void)initSession {
    YSF_NIMSession *session = [YSF_NIMSession session:_shopId type:YSF_NIMSessionTypeYSF];
    _session = session;
}

- (void)makeHandlerAndDataSource {
    _layoutManager = [[YSFSessionViewLayoutManager alloc] initWithInputView:self.sessionInputView tableView:self.tableView];
    
    [self initSessionDataSource];
    [_reachability startNotifier];
    
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] conversationManager] addDelegate:self];
    [[[YSF_NIMSDK sharedSDK] loginManager] addDelegate:self];
    [[QYSDK sharedSDK] infoManager].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkChanged:)
                                                 name:YSFReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAVSessionChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidHide:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)initSessionDataSource {
    _sessionDataSource = [[YSFSessionMsgDataSource alloc] initWithSession:_session showTimeInterval:(5 * 60.0)];
    _sessionDataSource.delegate = self;
    //reset
    self.messagePageLimit = self.messagePageLimit > 0 ? self.messagePageLimit : 20;
    NSInteger limit = self.messagePageLimit;
    if (self.hideHistoryMessages) {
        if ([[[QYSDK sharedSDK] sessionManager] shouldRequestService:YES shopId:_shopId]) {
            if (![self isLastMessageKFBypassNotificationAndEnable]) {
                limit = 0;
            }
        }
    }
    [_sessionDataSource resetMessagesWithLimit:limit];
}

- (void)makeUI {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[QYSDK sharedSDK].infoManager initSessionViewControllerInfo];
    });
    self.view.backgroundColor = YSFRGB(0xf8f8f8);
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    self.navigationItem.title = [self sessionTitle];
    /**
     *  设置导航栏右上角按钮：人工、商铺、评价、退出、更多
     */
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
    UIColor *itemColor = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? YSFRGB(0x76838f) : [UIColor whiteColor];
    //人工按钮
    _humanService = [[UIButton alloc] init];
    [_humanService addTarget:self action:@selector(onHumanChat:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_humanService];
    
    _humanServiceText = [[UIButton alloc] init];
    _humanServiceText.titleLabel.font = [UIFont systemFontOfSize:10];
    [_humanServiceText setTitleColor:itemColor forState:UIControlStateNormal];
    if ([QYCustomUIConfig sharedInstance].humanButtonText.length) {
        [_humanServiceText setTitle:[QYCustomUIConfig sharedInstance].humanButtonText forState:UIControlStateNormal];
    } else {
        [_humanServiceText setTitle:@"人工" forState:UIControlStateNormal];
    }
    [_humanServiceText addTarget:self action:@selector(onHumanChat:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_humanServiceText];
    //商铺按钮
    _shopEntrance = [[UIButton alloc] init];
    _shopEntrance.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_shopEntrance addTarget:self action:@selector(onShopEntranceTap:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_shopEntrance];
    
    _shopEntranceText = [[UIButton alloc] init];
    _shopEntranceText.titleLabel.font = [UIFont systemFontOfSize:10];
    _shopEntranceText.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _shopEntranceText.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_shopEntranceText setTitleColor:itemColor forState:UIControlStateNormal];
    [_shopEntranceText setTitle:[QYCustomUIConfig sharedInstance].shopEntranceText forState:UIControlStateNormal];
    [_shopEntranceText addTarget:self action:@selector(onShopEntranceTap:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_shopEntranceText];
    //评价按钮
    _evaluation = [[UIButton alloc] init];
    [_evaluation addTarget:self action:@selector(onEvaluate:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_evaluation];
    
    _evaluationText = [[UIButton alloc] init];
    _evaluationText.titleLabel.font = [UIFont systemFontOfSize:10];
    [_evaluationText setTitleColor:itemColor forState:UIControlStateNormal];
    [_evaluationText addTarget:self action:@selector(onEvaluate:) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonView addSubview:_evaluationText];
    
    if ([[QYSDK sharedSDK] customUIConfig].showCloseSessionEntry) {
        //退出按钮
        _closeSession = [[UIButton alloc] init];
        _closeSession.imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *imgName = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_close_session_black" : @"icon_close_session_white";
        [_closeSession setImage:[[UIImage ysf_imageInKit:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
        [_closeSession addTarget:self action:@selector(onCloseSession:) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_closeSession];
        
        _closeSessionText = [[UIButton alloc] init];
        _closeSessionText.titleLabel.font = [UIFont systemFontOfSize:10];
        [_closeSessionText setTitle:@"退出" forState:UIControlStateNormal];
        [_closeSessionText setTitleColor:itemColor forState:UIControlStateNormal];
        [_closeSessionText addTarget:self action:@selector(onCloseSession:) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_closeSessionText];
        //更多按钮
        _moreButton = [[UIButton alloc] init];
        _moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        imgName = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_more_black" : @"icon_more_white";
        [_moreButton setImage:[[UIImage ysf_imageInKit:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_moreButton];
        
        _moreButtonText = [[UIButton alloc] init];
        _moreButtonText.titleLabel.font = [UIFont systemFontOfSize:10];
        [_moreButtonText setTitle:@"更多" forState:UIControlStateNormal];
        [_moreButtonText setTitleColor:itemColor forState:UIControlStateNormal];
        [_moreButtonText addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
        [rightButtonView addSubview:_moreButtonText];
    }
    [self initRightCustomButtonStatus];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    /**
     *  设置聊天界面 TableView
     */
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[QYCustomUIConfig sharedInstance] sessionBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    /**
     *  设置下拉刷新 RefreshControl
     */
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(headerRereshing:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    /**
     *  设置输入条 YSFInputView
     */
    self.sessionInputView = [[YSFInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.ysf_frameWidth, YSFTopInputViewHeight)
                                                      inputType:g_inputStatus];
    _sessionInputView.containerController = self;
    [_sessionInputView setInputActionDelegate:self];
    __weak typeof(self) weakSelf = self;
    [_sessionInputView setActionCallback:^(YSFActionInfo *action) {
        if (action.action == YSFActionTypeSend) {
            [weakSelf onSendText:action.title];
        }
        QYButtonInfo *qyActionInfo = [[QYButtonInfo alloc] init];
        qyActionInfo.buttonId = action.buttonId;
        qyActionInfo.title = action.title;
        qyActionInfo.userData = action.userData;
        qyActionInfo.actionType = action.action;
        qyActionInfo.index = [weakSelf.sessionInputView.actionBar.actionInfoArray indexOfObjectIdenticalTo:action];
        if (weakSelf.buttonClickBlock) {
            weakSelf.buttonClickBlock(qyActionInfo);
        }
    }];
    [self.view addSubview:_sessionInputView];
    /**
     *  设置上方提醒条 YSFSessionTipView / YSFRecordTipView
     */
    _tipView = [[YSFSessionTipView alloc] initWithFrame:CGRectZero];
    _tipView.delegate = self;
    [_tipView setSessionTip:[_reachability isReachable] ? YSFSessionTipOK : YSFSessionTipNetworkError];
    [self.view addSubview:_tipView];
    
    _recordTipView = [[YSFRecordTipView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_recordTipView];
    /**
     *  设置会话列表入口,需放在top层
     */
    if ([QYCustomUIConfig sharedInstance].showSessionListEntrance) {
        [self showSessionListEntrance];
    }
    //若初次进入时无需请求客服已存在会话，则显示退出按钮并更新评价等信息
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    if (![sessionManager shouldRequestService:YES shopId:_shopId]) {
        YSFServiceSession *session = [sessionManager getOnlineSession:_shopId];
        if (session) {
            _closeSession.hidden = NO;
            _closeSession.enabled = YES;
            _closeSessionText.hidden = NO;
            _closeSessionText.enabled = YES;
            [self changeRightButtonItemState:session.humanOrMachine operatorEnable:session.operatorEable];
            
            if (session.humanOrMachine) {
                [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
                NSDictionary *recentDict = [sessionManager getRecentEvaluationMemoryDataByShopId:_shopId];
                if (recentDict && recentDict.count) {
                    NSNumber *sessionId = [recentDict objectForKey:YSFEvaluationSessionId];
                    if ([sessionId longLongValue] == session.sessionId) {
                        NSNumber *sessionTimes = [recentDict objectForKey:YSFEvaluationSessionTimes];
                        if ([sessionTimes integerValue] == -1) {
                            [self changeEvaluationButtonToDone];
                        } else {
                            [self changeEvaluationButtonToEnable];
                        }
                    }
                }
            } else {
                [_sessionInputView setActionInfoArray:session.actionInfoArray];
            }
        }
    }
    /**
     *  设置联想栏 YSFQuickReplyContentView
     */
    _quickReplyView = [[YSFQuickReplyContentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.sessionInputView.bounds), 0)];
    _quickReplyView.delegate = self;
    _quickReplyView.onlyMatchFirst = YES;
    _quickReplyView.backgroundColor = [UIColor whiteColor];
    _quickReplyView.layer.shadowOffset = CGSizeMake(0, -1);
    _quickReplyView.layer.shadowColor = YSFColorFromRGBA(0xE2E2E2, 0.5).CGColor;
}


#pragma mark - RightBarButtonItem
- (void)initRightCustomButtonStatus {
    NSString *shopEntranceIcon = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_shopEntrance_black" : @"icon_shopEntrance_white";
    if ([QYCustomUIConfig sharedInstance].shopEntranceImage) {
        [_shopEntrance setImage:[QYCustomUIConfig sharedInstance].shopEntranceImage forState:UIControlStateNormal];
    } else {
        [_shopEntrance setImage:[[UIImage ysf_imageInKit:shopEntranceIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
    }
    
    NSString *humanServiceIcon = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_humanService_black" : @"icon_humanService_white";
    [_humanService setImage:[[UIImage ysf_imageInKit:humanServiceIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                   forState:UIControlStateNormal];
    
    _humanService.hidden = YES;
    _humanServiceText.hidden = YES;
    _shopEntrance.hidden = ![QYCustomUIConfig sharedInstance].showShopEntrance;
    _shopEntranceText.hidden = ![QYCustomUIConfig sharedInstance].showShopEntrance;
    _closeSession.hidden = YES;
    _closeSessionText.hidden = YES;
    
    [self changeEvaluationButtonToInit];
    [self setRightButtonViewFrame];
}

- (void)changeRightButtonItemState:(BOOL)humanOrMachine operatorEnable:(BOOL)operatorEnable {
    if (_changeHumanOrRobotBlock) {
        _changeHumanOrRobotBlock(humanOrMachine);
    }
    if (!humanOrMachine) {
        self.sessionInputView.humanOrMachine = NO;
        if (operatorEnable) {
            _humanService.hidden = NO;
            _humanServiceText.hidden = NO;
        } else {
            _humanService.hidden = YES;
            _humanServiceText.hidden = YES;
        }
        _evaluation.hidden = YES;
        _evaluationText.hidden = YES;
        _closeSession.hidden = YES;
        _closeSessionText.hidden = YES;
    } else {
        self.sessionInputView.humanOrMachine = YES;
        _humanService.hidden = YES;
        _humanServiceText.hidden = YES;
        if ([QYCustomUIConfig sharedInstance].showEvaluationEntry) {
            _evaluation.hidden = NO;
            _evaluationText.hidden = NO;
        }
        _closeSession.hidden = NO;
        _closeSessionText.hidden = NO;
        _closeSession.enabled = YES;
        _closeSessionText.enabled = YES;
    }
    [self setRightButtonViewFrame];
}

- (void)setRightButtonViewFrame {
    if (!_shopEntrance.hidden && !_evaluation.hidden && _closeSession && !_closeSession.hidden) {
        _evaluation.alpha = 0;
        _evaluationText.alpha = 0;
        _closeSession.alpha = 0;
        _closeSessionText.alpha = 0;
        _moreButton.hidden = NO;
        _moreButtonText.hidden = NO;
    } else {
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
        } else {
            _shopEntrance.frame = CGRectMake(0, 0, 50, 20);
            _shopEntranceText.frame = CGRectMake(10, 20, 30, 20);
        }
        if (!_closeSession || _closeSession.hidden) {
            _humanService.frame = CGRectMake(40, 0, 50, 20);
            _humanServiceText.frame = CGRectMake(40, 20, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        } else {
            _humanService.frame = CGRectMake(0, 0, 50, 20);
            _humanServiceText.frame = CGRectMake(0, 20, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        }
        _closeSession.frame = CGRectMake(40, 0, 50, 20);
        _closeSessionText.frame = CGRectMake(40, 20, 50, 20);
        _moreButton.frame = CGRectMake(40, 0, 50, 20);
        _moreButtonText.frame = CGRectMake(40, 20, 50, 20);
    } else {
        if (_evaluation.hidden && _humanService.hidden && (!_closeSession || _closeSession.hidden)) {
            _shopEntrance.frame = CGRectMake(40, 1, 50, 20);
            _shopEntranceText.frame = CGRectMake(50, 17, 30, 20);
        } else {
            _shopEntrance.frame = CGRectMake(0, 1, 50, 20);
            _shopEntranceText.frame = CGRectMake(10, 17, 30, 20);
        }
        if (!_closeSession || _closeSession.hidden) {
            _humanService.frame = CGRectMake(40, 1, 50, 20);
            _humanServiceText.frame = CGRectMake(40, 17, 50, 20);
            _evaluation.frame = _humanService.frame;
            _evaluationText.frame = _humanServiceText.frame;
        } else {
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

- (void)showSessionListEntrance {
    UIImageView *sessionListImageView = [[UIImageView alloc] init];
    sessionListImageView.alpha = 0.6;
    sessionListImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.sessionListImageView = sessionListImageView;
    
    UIButton *sessionListButton = [[UIButton alloc] init];
    sessionListButton.backgroundColor = [UIColor clearColor];
    [sessionListButton addTarget:self action:@selector(onTapSessionListButton:) forControlEvents:UIControlEventTouchUpInside];
    self.sessionListButton = sessionListButton;
    
    [self setSessionListEntranceFrame];
    
    //YES: 右上角  NO: 左上角
    if ([QYCustomUIConfig sharedInstance].sessionListEntrancePosition) {
        if ([QYCustomUIConfig sharedInstance].sessionListEntranceImage) {
            sessionListImageView.image = [QYCustomUIConfig sharedInstance].sessionListEntranceImage;
        } else {
            sessionListImageView.image = [UIImage ysf_imageInKit:@"icon_sessionListEntrance_right"];
        }
    } else {
        if ([QYCustomUIConfig sharedInstance].sessionListEntranceImage) {
            sessionListImageView.image = [QYCustomUIConfig sharedInstance].sessionListEntranceImage;
        } else {
            sessionListImageView.image = [UIImage ysf_imageInKit:@"icon_sessionListEntrance_left"];
        }
    }
    [self.view addSubview:sessionListImageView];
    [self.view addSubview:sessionListButton];
}

- (void)setSessionListEntranceFrame {
    if ([QYCustomUIConfig sharedInstance].sessionListEntrancePosition) {
        _sessionListImageView.frame = CGRectMake(YSFUIScreenWidth - 42, YSFNavigationBarHeight + 20, 42, 42);
        _sessionListButton.frame = CGRectMake(YSFUIScreenWidth - 42, YSFNavigationBarHeight + 20, 42, 42);
    } else {
        _sessionListImageView.frame = CGRectMake(0, YSFNavigationBarHeight + 20, 42, 42);
        _sessionListButton.frame = CGRectMake(0, YSFNavigationBarHeight + 20, 42, 42);
    }
}

#pragma mark - UI相关更新
- (void)changeToWaitingState:(BOOL)robotInQueue {
    self.sessionInputView.humanOrMachine = !robotInQueue;
    _humanService.hidden = YES;
    _humanServiceText.hidden = YES;
    _evaluation.hidden = YES;
    _evaluationText.hidden = YES;
    _closeSession.hidden = NO;
    _closeSessionText.hidden = NO;
    _closeSession.enabled = YES;
    _closeSessionText.enabled = YES;
    [self setRightButtonViewFrame];
}

- (void)changeToNotExsitState:(YSFServiceSession *)session {
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

- (void)changeToNotExsitAndLeaveMessageClosedState:(YSFServiceSession *)session {
    [self changeToNotExsitState:session];
    [self disableInputView:@"客服不在线，不支持留言"];
}

- (void)disableInputView:(NSString *)text {
    [self.sessionInputView changeInputTypeToText];
    self.sessionInputView.toolBar.inputTextView.textColor = [UIColor lightGrayColor];
    self.sessionInputView.toolBar.inputTextView.editable = NO;
    self.sessionInputView.toolBar.voiceBtn.enabled = NO;
    self.sessionInputView.toolBar.emoticonBtn.enabled = NO;
    self.sessionInputView.toolBar.imageButton.enabled = NO;
    self.sessionInputView.toolBar.inputTextView.text = text;
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount {
    _leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    _leftBarView.badgeView.hidden = !unreadCount;
}

- (void)clearQuickReplyView {
    [self.quickReplyView removeFromSuperview];
    self.quickReplyView.ysf_frameHeight = 0;
    self.quickReplyView.ysf_frameBottom = self.sessionInputView.ysf_frameTop;
}

#pragma mark - Action
- (void)onHumanChat:(id)sender {
    [self clearRequestServiceParameter];
    [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneNavHumanButton onlyManual:YES clearSession:YES];
}

- (void)onShopEntranceTap:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onTapShopEntrance)]) {
        [_delegate onTapShopEntrance];
    }
}

- (void)onEvaluate:(id)sender {
    YSFLogApp(@"");
    [_popTipView dismissAnimated:YES];
    
    NSDictionary *recentDict = [[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId];
    long long sessionId = [(NSNumber *)[recentDict objectForKey:YSFEvaluationSessionId] longLongValue];
    [self showEvaluationViewControllerWithSessionId:sessionId];
}

- (void)onCloseSession:(id)sender {
    [self onCloseSessionWith:YES showQuitWaitingBlock:nil];
}

- (void)onMore:(id)sender {
    UIView *tipView = [[UIView alloc] init];
    tipView.userInteractionEnabled = YES;
    tipView.frame = CGRectMake(0, 0, 90, 100);
    //评价
    UIButton *evaluation = [[UIButton alloc] init];
    evaluation.frame = CGRectMake(0, 0, 90, 50);
    evaluation.titleLabel.font = [UIFont systemFontOfSize:15];
    [evaluation setTitle:_evaluationText.titleLabel.text forState:UIControlStateNormal];
    [evaluation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [evaluation setImage:_evaluation.imageView.image forState:UIControlStateNormal];
    evaluation.enabled = _evaluation.enabled;
    if (evaluation.titleLabel.text.length == 3) {
        tipView.ysf_frameWidth = 104;
        evaluation.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
        evaluation.titleEdgeInsets = UIEdgeInsetsMake(0, 19, 0, 0);
    } else {
        evaluation.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        evaluation.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    [evaluation addTarget:self action:@selector(onEvaluate:) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:evaluation];
    //退出
    UIButton *close = [[UIButton alloc] init];
    close.frame = CGRectMake(0, 50, 90, 50);
    close.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    close.titleLabel.font = [UIFont systemFontOfSize:15];
    [close setTitle:@"退出" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    close.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [close setImage:_closeSession.imageView.image forState:UIControlStateNormal];
    close.enabled = _closeSession.enabled;
    [close addTarget:self action:@selector(onCloseSession:) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:close];
    
    UIView *splitLine = [[UIView alloc] init];
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

- (void)onTapSessionListButton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onTapSessionListEntrance)]) {
        [_delegate onTapSessionListEntrance];
    }
}

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    [_sessionInputView inputBottomViewHeightToZero];
}

- (void)sendEvaluationRequest:(long long)sessionId
                        score:(NSUInteger)score
                      remarks:(NSString *)remarks
                       tagIds:(NSArray<YSFKaolaTagInfo *> *)tagInfos
                     callback:(void (^)(NSError *error))callback {
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

- (void)sendPicture:(UIImage *)picture {
    [self sendMessage:[YSFMessageMaker msgWithImage:picture]];
}

#pragma mark - 请求客服
- (BOOL)checkIfCanRequestStaffWithTip {
    //若最后一条消息是访客分流则提示用户选择分流类型
    if ([self isLastMessageKFBypassNotificationAndEnable]) {
        [self showToast:@"为了给您提供更专业的服务，请您选择要咨询的内容类型"];
        return NO;
    }
    if ([[[QYSDK sharedSDK] sessionManager] shouldRequestService:NO shopId:_shopId]) {
        //需要请求客服，需要等待客服连接成功后才去发送消息
        [self showToast:@"请等待连接客服成功后，再发送消息"];
        [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneNone onlyManual:NO clearSession:NO];
        //若客服不在线，可留言
        if (YSFSessionStateTypeNotExist == [[[QYSDK sharedSDK] sessionManager] getSessionStateType:_shopId]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)applyHumanStaff {
    [self clearRequestServiceParameter];
    [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneRobotUnable onlyManual:YES clearSession:YES];
}

- (void)requestHumanStaff {
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (!session
        || (session && !session.humanOrMachine)) {
        [self clearRequestServiceParameter];
        [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneActiveRequest onlyManual:YES clearSession:YES];
    }
}

- (void)changeHumanStaffWithStaffId:(int64_t)staffId
                            groupId:(int64_t)groupId
                           closetip:(NSString *)closetip
                    closeCompletion:(QYCompletion)closeCompletion
                  requestCompletion:(QYCompletion)requestCompletion {
    //1.关闭当前会话
    __weak typeof(self) weakSelf = self;
    [self closeSessionForChangeStaffWithClosetip:closetip completion:^(BOOL success, NSError *error) {
        if (success) {
            //2-1.关闭会话成功，发起新会话
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.staffId = staffId;
            strongSelf.groupId = groupId;
            strongSelf.changeStaffCompletion = requestCompletion;
            [self clearRequestServiceParameter];
            [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneChangeStaff onlyManual:YES clearSession:YES];
        } else {
            //2-2.关闭会话失败，终止
            if (closeCompletion) {
                closeCompletion(success, error);
            }
        }
    }];
}

- (void)requestServiceIfNeededInScene:(QYRequestStaffBeforeScene)scene onlyManual:(BOOL)onlyManual clearSession:(BOOL)clear {
    if ([self isLastMessageKFBypassNotificationAndEnable]) {
        return;
    }
    [[QYSDK sharedSDK] sessionManager].delegate = self;
    self.onlyManual = onlyManual;
    self.requestScene = scene;
    
    BOOL isInit = (QYRequestStaffBeforeSceneInit == scene);
    if (clear || [[[QYSDK sharedSDK] sessionManager] shouldRequestService:isInit shopId:_shopId]) {
        if ([QYCustomActionConfig sharedInstance].actionBlock) {
            [self blockStartRequestStaffWithClearSession:clear];
        } else {
            [self startRequestStaffWithClearSession:clear];
        }
    } else {
        if (isInit) {
            [self throwRequestStaffAfterBlock];
        }
    }
}

- (void)throwRequestStaffAfterBlock {
    if ([QYCustomActionConfig sharedInstance].actionBlock) {
        QYAction *action = [[QYAction alloc] init];
        action.type = QYActionTypeRequestStaffAfter;
        [QYCustomActionConfig sharedInstance].actionBlock(action);
        if (action.requestStaffAfterBlock) {
            YSFServiceSession *onlineSession = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
            action.requestStaffAfterBlock(onlineSession ? [onlineSession toDict] : nil, nil);
        }
    }
}

- (void)blockStartRequestStaffWithClearSession:(BOOL)clear {
    if ([QYCustomActionConfig sharedInstance].actionBlock) {
        QYAction *action = [[QYAction alloc] init];
        action.type = QYActionTypeRequestStaffBefore;
        [QYCustomActionConfig sharedInstance].actionBlock(action);
        if (action.requestStaffBeforeBlock) {
            __weak typeof(self) weakSelf = self;
            action.requestStaffBeforeBlock(self.requestScene, ^(BOOL continueIfNeeded) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (continueIfNeeded) {
                    [strongSelf startRequestStaffWithClearSession:clear];
                }
            });
        }
    }
}

- (void)startRequestStaffWithClearSession:(BOOL)clear {
    if (clear) {
        [[[QYSDK sharedSDK] sessionManager] clearByShopId:_shopId];
    }
    [[YSFSearchQuestionSetting sharedInstance:_shopId] clear];
    self.hasRequested = YES;
    _evaluation.enabled = NO;
    if (_changeEvaluationEnabledBlock) {
        _changeEvaluationEnabledBlock(NO);
    }
    _evaluationText.enabled = NO;
    YSFRequestServiceRequest *request = [[YSFRequestServiceRequest alloc] init];
    request.source = _source;
    request.onlyManual = self.onlyManual;
    request.groupId = _groupId;
    request.staffId = _staffId;
    request.robotId = _robotId;
    request.vipLevel = _vipLevel;
    request.entryId = _entryId;
    request.commonQuestionTemplateId = _commonQuestionTemplateId;
    request.openRobotInShuntMode = _openRobotInShuntMode;
    [[[QYSDK sharedSDK] sessionManager] requestServiceWithSource:request shopId:_shopId];
}

- (void)clearRequestServiceParameter {
    _entryId = 0;
}

#pragma mark - 访客分流
- (void)showBypassViewController:(YSF_NIMMessage *)message {
    if ([QYCustomUIConfig sharedInstance].bypassDisplayMode == QYBypassDisplayModeNone) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(message.messageObject) attachment];
    YSFBypassViewController *vc = [[YSFBypassViewController alloc] initWithByPassNotificatioin:(YSFKFBypassNotification *)attachment
                                                                                      callback:^(BOOL done, NSDictionary *bypassDict) {
                                       if (done) {
                                           [weakSelf requestByBypassDict:message entryDict:bypassDict];
                                       }
                                   }];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)requestByBypassDict:(YSF_NIMMessage *)message entryDict:(NSDictionary *)entryDict {
    [[[QYSDK sharedSDK] sessionManager] clearByShopId:_shopId];
    [self clearRequestServiceParameter];
    
    YSF_NIMCustomObject *customObject = message.messageObject;
    YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
    notification.disable = YES;
    [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:_session completion:nil];
    
    long long kfId = [(NSNumber *)[entryDict objectForKey:YSFApiKeyId] longLongValue];
    _entryId = [(NSNumber *)[entryDict objectForKey:YSFApiKeyEntryId] longLongValue];
    NSInteger type = [(NSNumber *)[entryDict objectForKey:YSFApiKeyType] integerValue];
    if (type == 1) {
        _groupId = kfId;
    } else if (type == 2) {
        _staffId = kfId;
    }
    [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneNone onlyManual:YES clearSession:NO];
}

//最后一条消息是否是访客分流信息并且能够点击
- (BOOL)isLastMessageKFBypassNotificationAndEnable {
    YSF_NIMMessage *lastMessage = [self getLastMessage];
    if (lastMessage && lastMessage.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = lastMessage.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
            YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
            if (!notification.disable) {
                return YES;
            }
        }
    }
    return NO;
}

//最后一条消息是否是访客分流信息
- (BOOL)isLastMessageKFBypassNotification {
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
- (void)resetKFBypassNotificationStatus {
    if ([self isLastMessageKFBypassNotification]) {
        YSF_NIMMessage *lastMessage = [self getLastMessage];
        YSF_NIMCustomObject *customObject = lastMessage.messageObject;
        YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
        notification.disable = NO;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:lastMessage forSession:_session completion:nil];
    }
}

//注：必须取本地存储的message，recentSession中的lastMesaage因异步存储存在问题导致不同步
- (YSF_NIMMessage *)getLastMessage {
    YSF_NIMMessage *lastMessage = nil;
    id model = [[_sessionDataSource modelArray] lastObject];
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        lastMessage = ((YSFMessageModel *)model).message;
    }
    //若收起历史消息开关打开，且此时modelArray没有数据，取不到lastMessage，则需从DB中取最后一条消息
    if (self.hideHistoryMessages && _sessionDataSource.modelArray.count == 0 && !lastMessage) {
        lastMessage = [self getLastMessageFromDB];
    }
    return lastMessage;
}

- (YSF_NIMMessage *)getLastMessageFromDB {
    return [_sessionDataSource getLastMessageFromDB];
}

#pragma mark - 消息收发
- (void)sendMessage:(YSF_NIMMessage *)message {
    [_inputtingMessageTimer stop];
    [_inputAssociateTimer stop];
    
    //在发送消息的接口判断是否有在线客服，若没有则请求客服
    if ([self checkIfCanRequestStaffWithTip]) {
        [self updateEvaluationSessionTimesBeforeRequestStaff];
        [[[YSF_NIMSDK sharedSDK] chatManager] sendMessage:message toSession:_session error:nil];
    }
}

- (void)updateEvaluationSessionTimesBeforeRequestStaff {
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (session && session.humanOrMachine) {
        NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId] mutableCopy];
        if (recentDict && recentDict.count) {
            NSNumber *sessionTimes = [recentDict objectForKey:YSFEvaluationSessionTimes];
            if (sessionTimes) {
                BOOL needSave = NO;
                NSInteger times = sessionTimes.integerValue;
                if (times == 0) {
                    times = 1;
                    needSave = YES;
                } else if (times == 2) {
                    times = 3;
                    needSave = YES;
                }
                if (needSave) {
                    [recentDict setValue:@(times) forKey:YSFEvaluationSessionTimes];
                    [[[QYSDK sharedSDK] sessionManager] setRecentEvaluationData:recentDict shopId:_shopId];
                }
            }
        }
    }
}

#pragma mark YSF_NIMChatManagerDelegate
- (void)willSendMessage:(YSF_NIMMessage *)message {
    if ([message.session isEqual:_session]) {
        if ([self findModel:message]) {
            [self uiUpdateMessage:message];
        } else {
            [self uiAddMessages:@[message]];
        }
    }
}

- (void)sendMessage:(YSF_NIMMessage *)message didCompleteWithError:(NSError *)error {
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        NSInteger index = [self.sessionDataSource indexAtModelArray:model];
        [self.layoutManager updateCellAtIndex:index model:model];
        if (error) {
            if (![[YSFReachability reachabilityForInternetConnection] isReachable]) {
                [_tipView setSessionTip:YSFSessionTipNetworkError];
            }
        } else {
            [_tipView setSessionTip:YSFSessionTipNetworkOK];
        }
    }
}

-(void)sendMessage:(YSF_NIMMessage *)message progress:(CGFloat)progress {
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDataSource indexAtModelArray:model] model:model];
    }
}

- (void)onRecvMessages:(NSArray *)messages {
    YSF_NIMMessage *message = (YSF_NIMMessage *)[messages firstObject];
    if (![message.session isEqual:self.session] || !messages.count) {
        return;
    }
    [self uiAddMessages:messages];
    [[YSF_NIMSDK sharedSDK].conversationManager markAllMessageReadInSession:self.session];
    [[[QYSDK sharedSDK] sessionManager] reportPushMessageReadedStatus];
    
    id customObject = message.messageObject;
    if ([customObject isMemberOfClass:[YSF_NIMCustomObject class]]) {
        id object = ((YSF_NIMCustomObject *)customObject).attachment;
        if ([object isMemberOfClass:[YSFBotForm class]]) {
            [self displayFillInBotForm:message];
        } else if ([object isMemberOfClass:[YSFBotCustomObject class]]) {
            [self showBotCustomViewController:(YSFBotCustomObject *)object];
        }
    }
    
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (session) {
        if ([customObject isMemberOfClass:[YSF_NIMCustomObject class]]) {
            id object = ((YSF_NIMCustomObject *)customObject).attachment;
            //自动发送商品卡片
            //1、进入会话界面，首次请求客服，人工模式下始终发送卡片，机器人模式下判断autoSendInRobot决定是否发送
            //2、机器人模式下，转人工客服，收到XXX为您服务后发送卡片
            if (g_sessionId != session.sessionId && [object isMemberOfClass:[YSFStartServiceObject class]]) {
                g_sessionId = session.sessionId;
                if (session.humanOrMachine) {
                    [self sendCommodityInfoRequest:YES];
                } else {
                    if (self.autoSendInRobot) {
                        [self sendCommodityInfoRequest:YES];
                    }
                }
            }
            //处理部分客服信息替换情况
            if (session.humanOrMachine && [object isMemberOfClass:[YSFStartServiceObject class]]) {
                YSFStartServiceObject *staffObject = (YSFStartServiceObject *)object;
                //若设置了staffInfo的accessTip属性则更新接入语
                if (self.staffInfo.accessTip.length) {
                    staffObject.accessTip = self.staffInfo.accessTip;
                    [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES
                                                                        message:message
                                                                     forSession:_session
                                                                     completion:nil];
                }
            }
        }
        //更新评价相关信息
        if (session.humanOrMachine) {
            NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId] mutableCopy];
            if (recentDict && recentDict.count) {
                NSNumber *sessionTimes = [recentDict objectForKey:YSFEvaluationSessionTimes];
                if (sessionTimes) {
                    BOOL needSave = NO;
                    NSInteger times = sessionTimes.integerValue;
                    if (times == 1) {
                        times = 2;
                        needSave = YES;
                    } else if (times == 3) {
                        times = 4;
                        needSave = YES;
                    }
                    if (needSave) {
                        [recentDict setValue:@(times) forKey:YSFEvaluationSessionTimes];
                        [[[QYSDK sharedSDK] sessionManager] setRecentEvaluationData:recentDict shopId:_shopId];
                    }
                    if (times == 4) {
                        if (!self.presentedViewController) {
                            [_evaluation animation_shakeImageWithDuration];
                        }
                    }
                }
            }
        }
    }
}

- (void)onUpdateMessage:(YSF_NIMMessage *)message {
    if (![message.session isEqual:self.session]){
        return;
    }
    [self uiUpdateMessage:message];
}

- (void)onAddMessage:(YSF_NIMMessage *)message {
    if (![message.session isEqual:self.session]){
        return;
    }
    
    if (message.messageType == YSF_NIMMessageTypeCustom) {
        id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(message.messageObject) attachment];
        if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]]) {
            _currentInviteEvaluationMessage = message;
            [self popEvaluationViewControllerIfNeeded];
        } else if ([attachment isMemberOfClass:[YSFKFBypassNotification class]]) {
            [self showBypassViewController:message];
        }
    }
    [self uiAddMessages:@[message]];
    [[YSF_NIMSDK sharedSDK].conversationManager markAllMessageReadInSession:self.session];
}

- (void)fetchMessageAttachment:(YSF_NIMMessage *)message progress:(CGFloat)progress {
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDataSource indexAtModelArray:model] model:model];
    }
}

- (void)fetchMessageAttachment:(YSF_NIMMessage *)message didCompleteWithError:(NSError *)error {
    if ([message.session isEqual:_session]) {
        YSFMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDataSource indexAtModelArray:model] model:model];
    }
}

#pragma mark - 商品信息
- (void)sendCommodityInfo:(QYCommodityInfo *)commodityInfo {
    self.commodityInfo = commodityInfo;
    g_commodityInfo = _commodityInfo;
    [self sendCommodityInfoRequest:NO];
}

- (void)sendSelectedCommodityInfo:(QYSelectedCommodityInfo *)commodityInfo {
    YSFSelectedCommodityInfo *selectedGoods = [[YSFSelectedCommodityInfo alloc] init];
    selectedGoods.command = YSFCommandBotSend;
    selectedGoods.target = commodityInfo.target;
    selectedGoods.params = commodityInfo.params;
    selectedGoods.goods = commodityInfo;
    YSF_NIMMessage *selectedGoodsMessage = [YSFMessageMaker msgWithCustom:selectedGoods];
    [self sendMessage:selectedGoodsMessage];
}

- (void)sendCommodityInfoRequest:(BOOL)bAuto {
    //只有收到欢迎服务用语后才会发送一次
    if (_commodityInfo) {
        [_commodityInfo checkCommodityInfoValid];
        QYCommodityInfo *commodityInfoShow = [_commodityInfo copy];
        commodityInfoShow.bAuto = bAuto;
        if (_commodityInfo.sendByUser) {
            //仅将消息加入会话列表，但没有真正发送出去
            YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:commodityInfoShow];
            commodityInfoMessage.session = _session;
            commodityInfoMessage.from = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
            commodityInfoMessage.isDeliveried = YES;
            [self onAddMessage:commodityInfoMessage];
        } else {
            if (!_commodityInfo.show) {
                //发送消息，但不在会话列表中展示消息
                YSFSetCommodityInfoRequest *request = [[YSFSetCommodityInfoRequest alloc] init];
                request.commodityInfo = [commodityInfoShow encodeAttachment];
                [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:nil];
            } else {
                //发送消息，同时在会话列表中展示消息
                YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:commodityInfoShow];
                [self sendMessage:commodityInfoMessage];
            }
        }
        g_commodityInfo = _commodityInfo;
    }
}

#pragma mark - 评价
- (void)changeEvaluationButtonToInit {
    _evaluation.hidden = YES;
    _evaluationText.hidden = YES;
    [_evaluationText setTitle:@"评价" forState:UIControlStateNormal];
    NSString *iconName = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_evaluation_black" : @"icon_evaluation_white";
    [_evaluation setImage:[[UIImage ysf_imageInKit:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                 forState:UIControlStateNormal];
}

- (void)changeEvaluationButtonToEnable {
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
    NSString *iconName = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_evaluation_black" : @"icon_evaluation_white";
    [_evaluation setImage:[[UIImage ysf_imageInKit:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                 forState:UIControlStateNormal];
}

- (void)changeEvaluationButtonToDone {
    if (_changeEvaluationEnabledBlock) {
        _changeEvaluationEnabledBlock(NO);
    }
    if (![QYCustomUIConfig sharedInstance].showEvaluationEntry) {
        return;
    }
    //修复bug：若机器人模式下，已展示人工按钮，则无需再展示p已评价按钮
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (session && !session.humanOrMachine && !_humanService.hidden) {
        return;
    }
    _evaluation.hidden = NO;
    _evaluationText.hidden = NO;
    _evaluation.enabled = NO;
    _evaluationText.enabled = NO;
    [_evaluationText setTitle:@"已评价" forState:UIControlStateNormal];
    NSString *iconName = [QYCustomUIConfig sharedInstance].rightBarButtonItemColorBlackOrWhite ? @"icon_evaluation_done_black" : @"icon_evaluation_done_white";
    [_evaluation setImage:[[UIImage ysf_imageInKit:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                 forState:UIControlStateNormal];
}

- (BOOL)popEvaluationViewControllerIfNeeded {
    BOOL autoPopup = NO;
    NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationPersistDataByShopId:_shopId] mutableCopy];
    if (recentDict && recentDict.count) {
        autoPopup = [[recentDict objectForKey:YSFEvaluationAutoPopup] boolValue];
        if (autoPopup) {
            long long sessionId = [(NSNumber *)[recentDict objectForKey:YSFEvaluationAutoPopupSessionId] longLongValue];
            [self showEvaluationViewControllerWithSessionId:sessionId];
        }
    }
    return autoPopup;
}

- (void)showEvaluationViewControllerWithSessionId:(long long)sessionId {
    if (!sessionId) {
        return;
    }
    [self evaluationViewControlerWillAppear];
    
    NSDictionary *historyData = [[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:sessionId];
    if (historyData && historyData.count) {
        NSDictionary *evaluationData = [historyData objectForKey:YSFEvaluationData];
        if (evaluationData && evaluationData.count) {
            NSDictionary *resultData = [historyData objectForKey:YSFEvaluationResultData];
            YSFEvaluationCommitData *lastCommit = nil;
            if (resultData && resultData.count) {
                lastCommit = [YSFEvaluationCommitData instanceByDict:resultData];
            }
            BOOL modifyEnable = [[historyData objectForKey:YSFEvaluationModifyEnable] boolValue];
            __weak typeof(self) weakSelf = self;
            YSFEvaluationViewController *vc = [[YSFEvaluationViewController alloc] initWithEvaluationDict:evaluationData
                                                                                         evaluationResult:lastCommit
                                                                                                   shopId:_shopId
                                                                                                sessionId:sessionId
                                                                                             modifyEnable:modifyEnable
                                                                                       evaluationCallback:^(BOOL done, YSFEvaluationResult *result) {
                                                                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                                           [strongSelf updateEvaluationResult:result sessionId:sessionId done:done];
                                                                                       }];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)evaluationViewControlerWillAppear {
    [self.view endEditing:YES];
    [_sessionInputView removeKeyboardObserver];
}

- (void)updateEvaluationResult:(YSFEvaluationResult *)result sessionId:(long long)sessionId done:(BOOL)done {
    //修复bug#YSF-14096
    //evaluationViewControlerWillAppear中endEditing:在后台时不会触发键盘变更事件，导致键盘无法正常弹回
    [_sessionInputView inputBottomViewHeightToZero];
    [_sessionInputView addKeyboardObserver];
    //更新recent数据中evaluation_auto为NO
    NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId] mutableCopy];
    if (recentDict) {
        [recentDict setValue:@(NO) forKey:YSFEvaluationAutoPopup];
        [[[QYSDK sharedSDK] sessionManager] setRecentEvaluationData:recentDict shopId:_shopId];
    }
    if (!done) {
        return;
    }
    
    NSDictionary *sessionDict = [[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:result.sessionId];
    NSString *specialTip = @"";
    if (sessionDict) {
        specialTip = [sessionDict valueForKey:YSFEvaluationSpecialThanksText];
    }
    [self updateEvaluationMessageWithSessionId:result.sessionId specialThanksTip:specialTip];
}

- (void)updateEvaluationMessageWithSessionId:(long long)sessionId specialThanksTip:(NSString *)specialThanksTip {
    //最近一通会话评价数据
    BOOL saveRecent = NO;
    NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId] mutableCopy];
    //sessionId对应的历史会话评价数据
    BOOL saveHistory = NO;
    NSMutableDictionary *sessionDict = [[[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:sessionId] mutableCopy];
    
    //若评价的会话为最近一通会话，则将右上角评价按钮置灰/session_status更新为3，表明已评价过/session_times更新为-1
    long long recentSessionId = 0;
    if (recentDict) {
        recentSessionId = [(NSNumber *)[recentDict objectForKey:YSFEvaluationSessionId] longLongValue];
        if (sessionId == recentSessionId) {
            [self changeEvaluationButtonToDone];
            [recentDict setValue:@(3) forKey:YSFEvaluationSessionStatus];
            [recentDict setValue:@(-1) forKey:YSFEvaluationSessionTimes];
            saveRecent = YES;
        }
    }
    //若外部传入specialThanksTip则记录在历史会话数据中
    if (sessionDict && specialThanksTip.length) {
        [sessionDict setValue:specialThanksTip forKey:YSFEvaluationSpecialThanksText];
        saveHistory = YES;
    }
    //读出历史会话评价数据中的messageId/thanksText/modifyEnable/resultData
    NSString *messageId = @"";
    NSString *thanksText = @"";
    BOOL modifyEnable = NO;
    YSFEvaluationCommitData *resultData = nil;
    if (sessionDict) {
        messageId = [sessionDict objectForKey:YSFEvaluationMessageID];
        thanksText = [sessionDict objectForKey:YSFEvaluationThanksText];
        modifyEnable = [[sessionDict objectForKey:YSFEvaluationModifyEnable] boolValue];
        NSDictionary *resultDict = [sessionDict objectForKey:YSFEvaluationResultData];
        if (resultDict) {
            resultData = [YSFEvaluationCommitData instanceByDict:resultDict];
        }
    }
    //构建感谢评价消息Model
    YSFEvaluationTipObject *tipObject = [[YSFEvaluationTipObject alloc] init];
    tipObject.command = YSFCommandEvaluationTip;
    tipObject.sessionId = sessionId;
    tipObject.tipContent = thanksText;
    tipObject.tipResult = resultData.title;
    tipObject.specialThanksTip = specialThanksTip;
    //判断是否显示“修改评价”
    if (modifyEnable) {
        tipObject.tipModify = @" 修改评价";
    }
    //取出_currentInviteEvaluationMessage评价消息的sessionId
    long long currentInviteSessionId = 0;
    if (_currentInviteEvaluationMessage) {
        YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)_currentInviteEvaluationMessage.messageObject;
        YSFInviteEvaluationObject *evaluationObject = (YSFInviteEvaluationObject *)object.attachment;
        currentInviteSessionId = evaluationObject.sessionId;
    }
    NSString *newMsgId = nil;
    YSF_NIMMessage *updateMessage = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:messageId forSession:_session];
    if (updateMessage || (_currentInviteEvaluationMessage && currentInviteSessionId == recentSessionId)) {
        YSF_NIMMessage *message = updateMessage ? updateMessage : _currentInviteEvaluationMessage;
        YSF_NIMCustomObject *object = [[YSF_NIMCustomObject alloc] init];
        object.attachment = tipObject;
        message.messageObject = object;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES
                                                            message:message
                                                         forSession:_session
                                                         completion:nil];
        newMsgId = message.messageId;
        if (message == _currentInviteEvaluationMessage) {
            _currentInviteEvaluationMessage = nil;
        }
    } else {
        YSF_NIMMessage *message = [YSFMessageMaker msgWithCustom:tipObject];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                          message:message
                                                       forSession:_session
                                                   addUnreadCount:NO
                                                       completion:nil];
        newMsgId = message.messageId;
    }
    //更新messageId
    if (newMsgId.length) {
        [sessionDict setValue:newMsgId forKey:YSFEvaluationMessageID];
        saveHistory = YES;
    }
    //保存数据
    if (saveRecent) {
        [[[QYSDK sharedSDK] sessionManager] setRecentEvaluationData:recentDict shopId:_shopId];
    }
    if (saveHistory) {
        [[[QYSDK sharedSDK] sessionManager] setHistoryEvaluationData:sessionDict shopId:_shopId sessionId:sessionId];
    }
}

#pragma mark - 关闭会话/退出排队
- (void)onCloseSessionWith:(BOOL)quitSessionViewController showQuitWaitingBlock:(QYQuitWaitingBlock)showQuitWaitingBlock {
    [_popTipView dismissAnimated:YES];
    __weak typeof(self) weakSelf = self;
    YSFAlertController * alertController = nil;
    if ([[[QYSDK sharedSDK] sessionManager] getSessionStateType:_shopId] == YSFSessionStateTypeWaiting) {
        alertController = [YSFAlertController alertWithTitle:nil message:@"确认退出排队？"];
        [alertController addCancelActionWithHandler:nil];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf sendCloseSessionCustomMessage:YES
                          quitSessionViewController:quitSessionViewController
                               showQuitWaitingBlock:showQuitWaitingBlock];
        }]];
    } else {
        alertController = [YSFAlertController alertWithTitle:nil message:@"确认退出对话？"];
        [alertController addCancelActionWithHandler:nil];
        [alertController addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf sendCloseSessionCustomMessage:NO
                          quitSessionViewController:quitSessionViewController
                               showQuitWaitingBlock:showQuitWaitingBlock];
        }]];
    }
    [alertController showWithSender:nil controller:self animated:YES completion:nil];
}

- (void)sendCloseSessionCustomMessage:(BOOL)quitWaitingOrCloseSession
            quitSessionViewController:(BOOL)quitSessionViewController
                 showQuitWaitingBlock:(QYQuitWaitingBlock)showQuitWaitingBlock {
    [self showToast:quitWaitingOrCloseSession ? @"退出排队中" : @"退出对话中"];
    
    __weak typeof(self) weakSelf = self;
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    YSFCancelWaitingRequest *request = [[YSFCancelWaitingRequest alloc] init];
    request.sessionId = [sessionManager getOnlineOrWaitingSession:_shopId].sessionId;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error){
        if (error) {
            [self showToast:quitWaitingOrCloseSession ? @"退出排队失败，请稍后再试" : @"退出对话失败，请稍后再试"];
            if (quitWaitingOrCloseSession) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        } else {
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

- (void)sendCloseSessionCustomMessage:(BOOL)quitWaitingOrCloseSession completetionBlock:(void (^)(BOOL isSuccess))completetionBlock {
    [self showToast:quitWaitingOrCloseSession ? @"退出排队中" : @"退出对话中"];
    
    __weak typeof(self) weakSelf = self;
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    YSFCancelWaitingRequest *request = [[YSFCancelWaitingRequest alloc] init];
    request.sessionId = [sessionManager getOnlineOrWaitingSession:_shopId].sessionId;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error){
        if (error) {
            [self showToast:quitWaitingOrCloseSession ? @"退出排队失败，请稍后再试" : @"退出对话失败，请稍后再试"];
            if (quitWaitingOrCloseSession) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        } else {
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

- (void)closeSessionForChangeStaffWithClosetip:(NSString *)closetip completion:(QYCompletion)completion {
    YSFCancelWaitingRequest *request = [[YSFCancelWaitingRequest alloc] init];
    request.sessionId = [[[QYSDK sharedSDK] sessionManager] getOnlineOrWaitingSession:_shopId].sessionId;
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error){
        if (!error) {
            if (closetip.length) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                YSFNotification *notification = [[YSFNotification alloc] init];
                notification.command = YSFCommandNotification;
                notification.localCommand = YSFCommandSessionWillClose;
                notification.message = closetip;
                YSF_NIMMessage *message = [YSFMessageMaker msgWithCustom:notification];
                YSF_NIMSession *session = [YSF_NIMSession session:strongSelf.shopId type:YSF_NIMSessionTypeYSF];
                [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:message forSession:session addUnreadCount:NO completion:nil];
            }
        }
        if (completion) {
            completion((error ? NO : YES), error);
        }
    }];
}

#pragma mark - NIMLoginDelegate
- (void)onLogin:(YSF_NIMLoginStep)step {
    YSFLogApp(@"step: %@", @(step));
    //若在会话界面内监听到同步完成,主动请求一次客服
    if (step == YSF_NIMLoginStepSyncOK && _hasRequested) {
        //快速进入会话窗口可能出现连接失败，故延后两秒请求客服，尽量规避此问题
        //若不延后，requestServiceIfNeededInScene执行时时可能刚好处在延时2秒提示请求结果的过程中
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf clearRequestServiceParameter];
            [weakSelf requestServiceIfNeededInScene:QYRequestStaffBeforeSceneNone onlyManual:NO clearSession:YES];
        });
    }
}

#pragma mark - YSFAppInfoManagerDelegate
- (void)didCreateAccountSuccessfully {
    //创建账号成功后重新进行初始化等待登录成功请求客服
    NSString *bid = [[QYSDK sharedSDK] infoManager].accountInfo.bid;
    if (bid) {
        _shopId = bid;
        [self initSession];
        [self initSessionDataSource];
    }
}

#pragma mark - YSFSessionProtocol
- (void)didBeginSendReqeustWithShopId:(NSString *)shopId {
    if (shopId && ![_shopId isEqualToString:shopId]) {
        return;
    }
    self.navigationItem.title = @"正在连接客服";
    [_tipView setSessionTip:YSFSessionTipOK];
}

- (void)didSendSessionRequest:(NSError *)error shopId:(NSString *)shopId {
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    if (error && error.code != YSF_NIMLocalErrorCodeUserInfoNeeded) {
        self.navigationItem.title = [self sessionTitle];
        [_tipView setSessionTip:YSFSessionTipRequestServiceFailed];
        [self resetKFBypassNotificationStatus];
    }
}

- (void)didReceiveSessionError:(NSError *)error session:(YSFServiceSession *)session shopId:(NSString *)shopId {
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    
    [self.tableView reloadData];
    self.navigationItem.title = [self sessionTitle];
    
    if (!error) {
        [_tipView setSessionTip:YSFSessionTipOK];
        if (session) {
            [self changeRightButtonItemState:session.humanOrMachine operatorEnable:session.operatorEable];
        }
        
        if (!session) {
            [self initRightCustomButtonStatus];
        } else if (session.humanOrMachine) {
            BOOL enable = YES;
            NSMutableDictionary *recentDict = [[[[QYSDK sharedSDK] sessionManager] getRecentEvaluationMemoryDataByShopId:_shopId] mutableCopy];
            if (recentDict && recentDict.count) {
                NSNumber *sessionId = [recentDict objectForKey:YSFEvaluationSessionId];
                if (sessionId && ([sessionId longLongValue] == session.sessionId)) {
                    enable = NO;
                    NSNumber *sessionTimes = [recentDict objectForKey:YSFEvaluationSessionTimes];
                    if (sessionTimes && ([sessionTimes integerValue] == -1)) {
                        [self changeEvaluationButtonToDone];
                    } else {
                        [self changeEvaluationButtonToEnable];
                    }
                }
            }
            if (enable) {
                [self changeEvaluationButtonToEnable];
            }
        }
        
        if (session.humanOrMachine) {
            [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
        } else {
            [_sessionInputView setActionInfoArray:session.actionInfoArray];
        }
        
        if (session && session.sessionId) {
            long long oldSessionID = [[QYSDK sharedSDK].sessionManager getLastSessionIdForShopId:shopId];
            if (session.sessionId == oldSessionID) {
                //若请求到的会话sessionId与本地保存的上一通会话sessionId相等，说明本次会话为未结束的旧会话
                //因该情况下不会收到欢迎语消息，故这里需要再次发送商品信息
                if (self.commodityInfo) {
                    if (g_sessionId != session.sessionId) {
                        g_sessionId = session.sessionId;
                        if (session.humanOrMachine) {
                            [self sendCommodityInfoRequest:YES];
                        } else {
                            if (self.autoSendInRobot) {
                                [self sendCommodityInfoRequest:YES];
                            }
                        }
                    }
                }
            }
            //若hideHistoryMessages为YES且已收起历史消息，则若为旧会话需加载出历史消息，否则一律收起历史消息
            if (self.hideHistoryMessages && self.sessionDataSource.modelArray.count == 0) {
                if (session.sessionId == oldSessionID) {
                    [self.sessionDataSource resetMessagesWithLimit:self.messagePageLimit];
                } else {
                    self.needShowHistoryTip = YES;
                }
            }
            
            [[QYSDK sharedSDK].sessionManager setLastSessionId:session.sessionId forShopId:shopId];
        }
    } else {
        if (error.code == YSFCodeServiceNotExist) {
            [self changeToNotExsitState:session];
            [_sessionInputView setActionInfoArray:_ysfActionInfoArray];
        } else if (error.code == YSFCodeServiceNotExistAndLeaveMessageClosed) {
            [self changeToNotExsitAndLeaveMessageClosedState:session];
        } else if (error.code == YSFCodeServiceWaiting) {
            [self changeToWaitingState:session.robotInQueue];
            [self queryWaitingStatus:shopId];
            [_tipView setSessionTipForWaiting:session.showNumber waitingNumber:session.before inQueeuStr:session.inQueeuNotify];
        } else {
            [_tipView setSessionTip:YSFSessionTipRequestServiceFailed];
        }
    }
    //抛出请求客服后的部分信息
    if ([QYCustomActionConfig sharedInstance].actionBlock) {
        QYAction *action = [[QYAction alloc] init];
        action.type = QYActionTypeRequestStaffAfter;
        [QYCustomActionConfig sharedInstance].actionBlock(action);
        if (action.requestStaffAfterBlock) {
            action.requestStaffAfterBlock([session toDict], error);
        }
    }
    if (self.requestScene == QYRequestStaffBeforeSceneChangeStaff) {
        if (self.changeStaffCompletion) {
            self.changeStaffCompletion(error ? NO : YES, error);
            self.changeStaffCompletion = nil;
        }
    }
}

- (void)didClose:(BOOL)evaluate session:(YSFServiceSession *)session shopId:(NSString *)shopId {
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    
    YSFServiceSession *onlineSession = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (onlineSession && onlineSession.sessionId == session.sessionId) {
        [self clearRequestServiceParameter];
        
        _closeSession.enabled = NO;
        _closeSessionText.enabled = NO;
        if (_evaluation.enabled && !self.presentedViewController && !evaluate) {
            [_evaluation animation_shakeImageWithDuration];
            _currentInviteEvaluationMessage = nil;
        }
    }
    [_sessionInputView setActionInfoArray:nil];
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
    
    if ([object isKindOfClass:[YSFQueryWaitingStatusResponse class]]) {
        YSFQueryWaitingStatusResponse *wait_status = object;
        NSError *error = (wait_status.code == YSFCodeSuccess) ? nil : [NSError errorWithDomain:YSFErrorDomain code:wait_status.code userInfo:nil];
        [self didReceiveWaitingStatus:error waitStatus:wait_status shopId:shopId];
        if (wait_status.code != YSFCodeSuccess) {
            [_queryWaitingStatusTimer stop];
        } else {
            [self queryWaitingStatus:shopId];
        }
    } else if ([object isKindOfClass:[YSFSendSearchQuestionResponse class]]) {
        if (_sessionInputView.toolBar.inputTextView.text.length == 0) {
            return;
        }
        YSFSendSearchQuestionResponse *sendSearchQuestionResponse = (YSFSendSearchQuestionResponse *)object;
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:sendSearchQuestionResponse.questionContents.count];
        _quickReplyView.searchText = sendSearchQuestionResponse.content;
        for (YSFQuickReplyKeyWordAndContent *content in sendSearchQuestionResponse.questionContents) {
            content.content = content.content;
            content.isContentRich = 0;
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
    } else if ([object isKindOfClass:[YSFBotEntry class]]) {
        [_sessionInputView setActionInfoArray:((YSFBotEntry *)object).entryArray];
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        if (sessionManager) {
            [sessionManager getOnlineSession:_shopId].actionInfoArray = ((YSFBotEntry *)object).entryArray;
        }
    } else if ([object isKindOfClass:[YSFRevokeMessageResult class]]) {
        YSFRevokeMessageResult *result = (YSFRevokeMessageResult *)object;
        if (result.resultCode == YSFCodeSuccess) {
            YSFServiceSession *onlineSession = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:shopId];
            if (onlineSession.sessionId == result.sessionId) {
                if (result.messageId.length) {
                    YSF_NIMMessage *message = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:result.messageId
                                                                                              forSession:_session];
                    if (message) {
                        if (!message.session) {
                            message.session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
                        }
                        [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:message];
                        [self uiDeleteMessage:message];
                        
                        YSFNotification *notification = [[YSFNotification alloc] init];
                        notification.command = YSFCommandNotification;
                        notification.localCommand = YSFCommandRevokeMessageResult;
                        NSString *tip = [NSString stringWithFormat:@"\"%@\" ", onlineSession.staffName];
                        if (result.message.length) {
                            tip = [tip stringByAppendingString:result.message];
                        } else {
                            tip = [tip stringByAppendingString:@"撤回了一条消息"];
                        }
                        notification.message = tip;
                        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
                        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                                          message:customMessage
                                                                       forSession:_session
                                                                   addUnreadCount:NO
                                                                       completion:nil];
                    }
                }
            }
        }
    }
}

- (void)didReceiveWaitingStatus:(NSError *)error waitStatus:(YSFQueryWaitingStatusResponse *)waitStatus shopId:(NSString *)shopId {
    if (![_shopId isEqualToString:shopId]) {
        return;
    }
    if (!error) {
        [_tipView setSessionTipForWaiting:waitStatus.showNumber
                            waitingNumber:waitStatus.waitingNumber
                               inQueeuStr:waitStatus.inQueeuNotify];
    }
}

- (void)queryWaitingStatus:(NSString *)shopId {
    [_queryWaitingStatusTimer start:dispatch_get_main_queue() interval:10 repeats:NO block:^{
        YSFQueryWaitingStatusRequest *request = [[YSFQueryWaitingStatusRequest alloc] init];
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:shopId completion:^(NSError *error) {}];
    }];
}

#pragma mark - YSF_NIMConversationManagerDelegate
- (void)messagesDeletedInSession:(YSF_NIMSession *)session {
    [self.sessionDataSource resetMessagesWithLimit:self.messagePageLimit];
    [self.tableView reloadData];
}

- (void)didAddRecentSession:(YSF_NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount {
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didUpdateRecentSession:(YSF_NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount {
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didRemoveRecentSession:(YSF_NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount {
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)changeUnreadCount:(YSF_NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount {
    if ([recentSession.session isEqual:self.session]) {
        return;
    }
    [self changeLeftBarBadge:totalUnreadCount];
}

#pragma mark - YSFSessionTipViewDelegate
- (void)tipViewRequestService:(YSFSessionTipView *)tipView {
    [self requestServiceIfNeededInScene:QYRequestStaffBeforeSceneNone onlyManual:NO clearSession:NO];
}

- (void)quitWaiting:(YSFSessionTipView *)tipView {
    __weak typeof(self) weakSelf = self;
    [self onCloseSessionWith:NO showQuitWaitingBlock:^(QuitWaitingType quitType) {
        if (quitType == QuitWaitingTypeQuit) {
            [weakSelf.queryWaitingStatusTimer stop];
            [weakSelf.tipView setSessionTip:YSFSessionTipOK];
            
            [[[QYSDK sharedSDK] sessionManager] clearByShopId:weakSelf.shopId];
            [self clearRequestServiceParameter];
            
            weakSelf.closeSession.enabled = NO;
            weakSelf.closeSessionText.enabled = NO;
        }
    }];
}

#pragma mark - YSFQuickReplyContentViewDelegate
- (void)didTapRowAtIndex:(NSUInteger)index data:(YSFQuickReplyKeyWordAndContent *)data {
    self.sessionInputView.toolBar.inputTextView.text = @"";
    [self.quickReplyView removeFromSuperview];
    [self sendMessage:[YSFMessageMaker msgWithText:data.content]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sessionDataSource msgCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    id model = [[_sessionDataSource modelArray] objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        cell = [YSFMessageCellMaker cellInTable:tableView forMessageMode:model];
        [(YSFMessageCell *)cell setMessageDelegate:self];
    } else if ([model isKindOfClass:[YSFTimestampModel class]]) {
        cell = [YSFMessageCellMaker cellInTable:tableView forTimeModel:model];
    } else {
        NSAssert(0, @"not support model");
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    id modelInArray = [[_sessionDataSource modelArray] objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[YSFMessageModel class]]) {
        YSFMessageModel *model = (YSFMessageModel *)modelInArray;
        
        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
        
        if (model.message.messageType == YSF_NIMMessageTypeCustom) {
            id<YSF_NIMCustomAttachment> attachment = [(YSF_NIMCustomObject *)(model.message.messageObject) attachment];
            if ([attachment isMemberOfClass:[YSFMachineResponse class]]) {
                NSRange range = [model.message.messageId rangeOfString:@"#"];
                long long ysfSessionId = 0;
                if (range.location != NSNotFound) {
                    ysfSessionId = [[model.message.messageId substringToIndex:range.location] longLongValue];
                }
                YSFMachineResponse *machineResponse = (YSFMachineResponse *)attachment;
                YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineOrWaitingSession:_shopId];
                machineResponse.shouldShow = (session.sessionId == ysfSessionId || session.robotSessionId == ysfSessionId);
                [model cleanCache];
            }
        }
        
        [self layoutConfig:model];
        CGSize size = model.contentSize;
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
    } else if ([modelInArray isKindOfClass:[YSFTimestampModel class]]) {
        cellHeight = [(YSFTimestampModel *)modelInArray height];
    }
    return cellHeight;
}

#pragma mark - table-数据源
- (YSFMessageModel *)makeModel:(YSF_NIMMessage *)message {
    YSFMessageModel *model = [self findModel:message];
    if (!model) {
        model = [[YSFMessageModel alloc] initWithMessage:message];
    }
    [self layoutConfig:model];
    return model;
}

- (YSFMessageModel *)findModel:(YSF_NIMMessage *)message {
    YSFMessageModel *model;
    for (YSFMessageModel *item in self.sessionDataSource.modelArray.reverseObjectEnumerator.allObjects) {
        if ([item isKindOfClass:[YSFMessageModel class]] && [item.message isEqual:message]) {
            model = item;
            //防止进了会话又退出再进这种行为；防止SDK回调上来的message和会话持有的message不是一个，导致刷界面crash的情况
            model.message = message;
        }
    }
    return model;
}

#pragma mark - table-UI更新
- (void)messageDataIsReady {
    [self.tableView reloadData];
    [self.tableView ysf_scrollToBottom:NO];
}

- (void)layoutConfig:(YSFMessageModel *)model {
    CGFloat contentWidth = self.tableView.ysf_frameWidth;
    if (@available(iOS 11, *)) {
        contentWidth -= self.view.safeAreaInsets.left + self.view.safeAreaInsets.right;
    }
    [model calculateContent:contentWidth];
}

- (void)headerRereshing:(id)sender {
    YSF_NIMMessage *tipMessage = nil;
    if (self.hideHistoryMessages && self.needShowHistoryTip && self.historyMessagesTip.length) {
        YSFNotification *notification = [[YSFNotification alloc] init];
        notification.command = YSFCommandNotification;
        notification.localCommand = YSFCommandLineNotification;
        notification.message = self.historyMessagesTip;
        tipMessage = [YSFMessageMaker msgWithCustom:notification];
    }
    __weak YSFSessionViewLayoutManager *layoutManager = self.layoutManager;
    __weak UIRefreshControl *refreshControl = self.refreshControl;
    __weak typeof(self) weakSelf = self;
    [self.sessionDataSource loadHistoryMessagesWithLimit:self.messagePageLimit
                                       historyTipMessage:tipMessage
                                              completion:^(NSInteger index, NSError *error) {
                                                  [layoutManager reloadDataToIndex:index withAnimation:NO];
                                                  [refreshControl endRefreshing];
                                                  weakSelf.needShowHistoryTip = NO;
                                              }];
}

- (void)uiAddMessages:(NSArray *)messages {
    NSArray *insert = [self.sessionDataSource addMessages:messages];
    for (YSF_NIMMessage *message in messages) {
        YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
        [self layoutConfig:model];
    }
    [self.layoutManager insertTableViewCellAtRows:insert scrollToBottom:YES];
}

- (void)uiDeleteMessage:(YSF_NIMMessage *)message {
    YSFMessageModel *model = [self makeModel:message];
    NSArray *indexs = [self.sessionDataSource deleteMessageModel:model];
    [self.layoutManager deleteCellAtIndexs:indexs];
}

- (void)uiUpdateMessage:(YSF_NIMMessage *)message {
    YSFMessageModel *model = [self makeModel:message];
    NSInteger index = [self.sessionDataSource indexAtModelArray:model];
    if (index > -1) {
        [model cleanLayoutConfig];
        [model cleanCache];
        model = [self makeModel:message];
        [self.sessionDataSource.modelArray replaceObjectAtIndex:index withObject:model];
        [self.layoutManager updateCellAtIndex:index model:model];
        
        BOOL shouldAutoScroll = (index == [self.sessionDataSource msgCount] - 1) && [_tableView ysf_isInBottom];
        [_tableView reloadData];
        if (shouldAutoScroll) {
            [_tableView ysf_scrollToBottom:YES];
        }
    }
}

#pragma mark - Cell Action
- (void)onTapCell:(YSFKitEvent *)event {
    __block BOOL handled = NO;
    NSString *eventName = event.eventName;
    YSF_NIMMessage *message = event.message;
    __block NSString *eventData = @"";
    
    if ([eventName isEqualToString:YSFKitEventNameReloadData]) {
        YSFMessageModel *model = [self makeModel:message];
        BOOL shouldAutoScroll = NO;
        NSInteger index = [self.sessionDataSource indexAtModelArray:model];
        if (index > -1) {
            shouldAutoScroll = (index == [self.sessionDataSource msgCount] - 1) && [_tableView ysf_isInBottom];
        }
        [_tableView reloadData];
        if (shouldAutoScroll) {
            [_tableView ysf_scrollToBottom:YES];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapContent]) {
        switch (message.messageType) {
            case YSF_NIMMessageTypeImage: {
                [self showImage:message touchView:event.data];
                handled = YES;
                break;
            }
            case YSF_NIMMessageTypeAudio: {
                [self onTapPlayAudio:event];
                handled = YES;
                break;
            }
            case YSF_NIMMessageTypeVideo: {
                [self onTapPlayVideo:message touchView:event.data];
                handled = YES;
                break;
            }
            case YSF_NIMMessageTypeFile: {
                [self onTapFileMessage:message];
                handled = YES;
                break;
            }
            default:
                break;
        }
    } else if ([eventName isEqualToString:YSFKitEventNameTapRichTextImage]) {
        [self showImage:message touchView:event.data];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapLabelPhoneNumber]) {
        UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:event.data
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:nil,nil];
        [dialog addButtonWithTitle:@"取消"];
        [dialog addButtonWithTitle:@"呼叫"];
        [dialog ysf_showWithCompletion:^(NSInteger index) {
            if (index == 1) {
                NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", event.data]];
                [[UIApplication sharedApplication] openURL:telURL];
            }
        }];
        eventData = [NSString stringWithFormat:@"tel://%@", YSFStrParam(event.data)];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapMachineQuestion]) {
        NSDictionary *questionDict = event.data;
        NSString *question = [questionDict objectForKey:YSFApiKeyQuestion];
        YSFServiceSession *session = [[QYSDK sharedSDK].sessionManager getOnlineSession:_shopId];
        if (session && !session.humanOrMachine) {
            NSNumber *questionId = [questionDict objectForKey:YSFApiKeyId];
            YSFReportQuestion *request = [[YSFReportQuestion alloc] init];
            request.command = YSFCommandReportQuestion;
            request.questionId = [questionId longLongValue];
            request.question = question;
            request.messageId = event.message.messageId;
            YSF_NIMMessage *questionMessage = [YSFMessageMaker msgWithCustom:request];
            [self sendMessage:questionMessage];
        } else {
            YSF_NIMMessage *message = [YSFMessageMaker msgWithText:question];
            [self sendMessage:message];
        }
        eventData = YSFStrParam(question);
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapEvaluationSelection]) {
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
    } else if ([eventName isEqualToString:YSFKitEventNameTapEvaluationReason]) {
        [self onTapEvaluationReasonWithMessage:message];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapLabelLink]) {
        NSString *url = event.data;
        if ([url matchEmailFormat]) {
            [self popEmailActionSheetWithStr:url];
            handled = YES;
        }
        
        NSDictionary *dict = [url ysf_paramsFromString];
        [dict.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *commandStr = obj;
            if ([commandStr isEqualToString:@"applyHumanStaff"]) {
                [self applyHumanStaff];
                eventData = YSFStrParam(commandStr);
                handled = YES;
            } else {
                NSAssert(NO, @"not support command");
            }
        }];
        if (handled == NO) {
            [self openUrl:url];
            eventData = YSFStrParam(url);
            handled = YES;
        }
    } else if ([eventName isEqualToString:YSFKitEventNameTapKFBypass]) {
        [self requestByBypassDict:event.message entryDict:event.data];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapCommodityInfo]) {
        YSF_NIMCustomObject *customObject = event.message.messageObject;
        QYCommodityInfo *commodityInfo = customObject.attachment;
        NSString *commodityUrl = commodityInfo.urlString;
        if (commodityUrl && ![commodityUrl isEqualToString:@""]) {
            eventData = YSFStrParam(commodityUrl);
            [self openUrl:commodityUrl];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapEvaluation]) {
        YSF_NIMCustomObject *customObject = event.message.messageObject;
        YSFInviteEvaluationObject *object = (YSFInviteEvaluationObject *)customObject.attachment;
        if (_onEvaluateBlock) {
            _onEvaluateBlock(object.sessionId, event.message);
        } else {
            [self showEvaluationViewControllerWithSessionId:object.sessionId];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapModifyEvaluation]) {
        YSF_NIMCustomObject *customObject = event.message.messageObject;
        YSFEvaluationTipObject *object = (YSFEvaluationTipObject *)customObject.attachment;
        NSDictionary *sessionData = [[[QYSDK sharedSDK] sessionManager] getHistoryEvaluationMemoryDataByShopId:_shopId sessionId:object.sessionId];
        long long timestamp_limit = 0;
        if (sessionData && sessionData.count) {
            id timestamp = [sessionData objectForKey:YSFEvaluationModifyLimit];
            if (timestamp) {
                timestamp_limit = [timestamp longLongValue];
            }
        }
        long long timestamp_now = round([[NSDate date] timeIntervalSince1970] * 1000);
        if (timestamp_now < timestamp_limit || timestamp_limit == 0) {
            //还未到达评价时效，可以评价
            if (_onEvaluateBlock) {
                _onEvaluateBlock(object.sessionId, event.message);
            } else {
                [self showEvaluationViewControllerWithSessionId:object.sessionId];
            }
        } else {
            [self showToast:@"评价已超时，无法进行评价"];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapGoods]) {
        QYSelectedCommodityInfo *goods = event.data;
        YSFSelectedCommodityInfo *selectedGoods = [[YSFSelectedCommodityInfo alloc] init];
        selectedGoods.command = YSFCommandBotSend;
        selectedGoods.target = goods.target;
        selectedGoods.params = goods.params;
        selectedGoods.goods = goods;
        YSF_NIMMessage *selectedGoodsMessage = [YSFMessageMaker msgWithCustom:selectedGoods];
        [self sendMessage:selectedGoodsMessage];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapMoreOrders]) {
        YSFOrderList *orderList = event.data;
        YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        vc.showTop = YES;
        vc.titleString = orderList.label;
        vc.action = orderList.action;
        vc.originalData = orderList.shops;

        __weak typeof(self) weakSelf = self;
        vc.tapItemCallback = ^(QYSelectedCommodityInfo *goods) {
            [weakSelf sendSelectedCommodityInfo:goods];
            return YES;
        };
        [self presentViewController:vc animated:YES completion:nil];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapMoreFlight]) {
        YSFFlightList *flightList = event.data;
        [self popUpMoreListNav:flightList];
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapBot]) {
        YSFAction *action = (YSFAction *)event.data;
        [self onTapBotAction:action];
        eventData = YSFStrParam([action toJsonString]);
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapMixReply]) {
        YSFAction *action = (YSFAction *)event.data;
        [self onTapMixReplyAction:action];
        eventData = YSFStrParam([action toJsonString]);
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapPushMessageActionUrl]) {
        [self onTapPushMessageActionUrl:event.data];
        eventData = YSFStrParam(event.data);
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapFillInBotForm]) {
        long long sessionId = event.message.sessionIdFromMessageId;
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        YSFServiceSession *session = [sessionManager getOnlineSession:_shopId];
        if (session.sessionId == sessionId) {
            [self displayFillInBotForm:event.message];
        } else {
            [self showToast:@"该会话已结束，表单已失效"];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameSendCommdityInfo]) {
        YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
        YSFServiceSession *session = [sessionManager getOnlineOrWaitingSession:_shopId];
        if (!session) {
            [self showToast:@"发送失败，会话已结束"];
        } else if (session && !session.humanOrMachine) {
            [self showToast:@"发送失败，机器人看不懂卡片哦"];
        } else {
            YSF_NIMCustomObject *customObject = event.message.messageObject;
            QYCommodityInfo *show = (QYCommodityInfo *)(customObject.attachment);
            QYCommodityInfo *showCopy = [show copy];
            showCopy.sendByUser = NO;
            YSF_NIMMessage *commodityInfoMessage = [YSFMessageMaker msgWithCustom:showCopy];
            [self sendMessage:commodityInfoMessage];
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapCommdityAction]) {
        if ([QYCustomActionConfig sharedInstance].commodityActionBlock) {
            YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)event.message.messageObject;
            YSFSelectedCommodityInfo *selectedGoods = (YSFSelectedCommodityInfo *)object.attachment;
            [QYCustomActionConfig sharedInstance].commodityActionBlock(selectedGoods.goods);
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapExtraViewAction]) {
        if ([QYCustomActionConfig sharedInstance].extraClickBlock) {
            if (event.message.ext.length) {
                NSDictionary *dict = [event.message.ext ysf_toDict];
                if (dict && dict.count) {
                    BOOL needShow = [[dict objectForKey:YSFApiKeyBotShowUseful] boolValue];
                    if (needShow) {
                        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES
                                                                         attachment:NO
                                                                            message:event.message
                                                                         forSession:_session
                                                                         completion:nil];
                        [QYCustomActionConfig sharedInstance].extraClickBlock(event.message.ext);
                        
                        //自定义行为
                        
                    }
                }
            }
        } else {
            //SDK内部行为
        }
        handled = YES;
    } else if ([eventName isEqualToString:YSFKitEventNameTapSystemNotification]) {
        if ([QYCustomActionConfig sharedInstance].notificationClickBlock) {
            [QYCustomActionConfig sharedInstance].notificationClickBlock(event.message);
        }
    }
    
    //抛出所有消息内点击事件
    if (event && [QYCustomActionConfig sharedInstance].eventClickBlock) {
        NSString *extEventName = [event transferEventNameForExternal];
        [QYCustomActionConfig sharedInstance].eventClickBlock(extEventName, eventData, event.message.messageId);
    }
    
    if (!handled) {
        //assert(0);
    }
}

- (NSDictionary *)cellActions {
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(YSF_NIMMessageTypeImage) : @"showImage:",
                    @(YSF_NIMMessageTypeAudio) : @"playAudio:",
                    @(YSF_NIMMessageTypeVideo) : @"showVideo:",
                    @(YSF_NIMMessageTypeLocation) : @"showLocation:",
                    @(YSF_NIMMessageTypeFile)  : @"showFile:",
                    @(YSF_NIMMessageTypeCustom): @"showCustom:"};
    });
    return actions;
}

- (void)popUpMoreListNav:(YSFFlightList *)flightList {
    YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
    vc.showTop = NO;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (flightList.detail == nil) {
        vc.navigationItem.title = flightList.action.title;
        vc.action = flightList.action;
        vc.originalData = flightList.fieldItems;
    } else {
        vc.navigationItem.title = flightList.detail.label;
        vc.originalData = flightList.detail.flightDetailItems;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(nav) weakNav = nav;
    vc.tapItemCallback = ^(YSFAction *action) {
        if ([action.type isEqualToString:@"url"] || [action.type isEqualToString:@"block"]) {
            [weakSelf onTapBotAction:action];
        } else {
            YSFMoreOrderListViewController *vc2 = [YSFMoreOrderListViewController new];
            vc2.action = action;
            [weakNav pushViewController:vc2 animated:YES];
            return NO;
        }
        return YES;
    };
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTapBotAction:(YSFAction *)action {
    if ([action.type isEqualToString:@"url"]) {
        QYBotClickBlock block = [QYCustomActionConfig sharedInstance].botClick;
        if (block) {
            block(action.target, action.params);
        }
    } else if ([action.type isEqualToString:@"float"]) {
        YSFMoreOrderListViewController *vc = [YSFMoreOrderListViewController new];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        vc.action = action;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([action.type isEqualToString:@"popup"]) {
        YSFFlightList *flightList = [YSFFlightList new];
        flightList.action = action;
        [self popUpMoreListNav:flightList];
    } else {
        YSFOrderOperation *orderOperation = [[YSFOrderOperation alloc] init];
        orderOperation.command = YSFCommandBotSend;
        orderOperation.target = action.target;
        orderOperation.params = action.params;
        orderOperation.templateInfo = @{@"id":@"qiyu_template_text", @"label":YSFStrParam(action.validOperation)};
        YSF_NIMMessage *orderOperationMessage = [YSFMessageMaker msgWithCustom:orderOperation];
        [self sendMessage:orderOperationMessage];
    }
}

- (void)onTapMixReplyAction:(YSFAction *)action {
    YSFOrderOperation *orderOperation = [[YSFOrderOperation alloc] init];
    orderOperation.command = YSFCommandBotSend;
    orderOperation.target = action.target;
    orderOperation.params = action.params;
    orderOperation.label = action.validOperation;
    orderOperation.type = action.type;
    orderOperation.templateInfo = @{@"id":@"qiyu_template_mixReply", @"label":YSFStrParam(action.validOperation)};
    YSF_NIMMessage *orderOperationMessage = [YSFMessageMaker msgWithCustom:orderOperation];
    [self sendMessage:orderOperationMessage];
}

- (void)onTapPushMessageActionUrl:(NSString *)actionUrl {
    QYLinkClickBlock block = [QYCustomActionConfig sharedInstance].pushMessageClick;
    if (block) {
        block(actionUrl);
    }
}

- (void)displayFillInBotForm:(YSF_NIMMessage *)message {
    [self.view endEditing:YES];
    [_sessionInputView removeKeyboardObserver];
    YSFBotFormViewController *vc = [YSFBotFormViewController new];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    YSF_NIMCustomObject *customObject = message.messageObject;
    YSFBotForm *botForm = (YSFBotForm *)customObject.attachment;
    vc.botForm = botForm;
    __weak typeof(self) weakSelf = self;
    vc.submitCallback = ^(BOOL submitted, YSFSubmittedBotForm *submittedBotForm) {
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
        } else {
            [self showToast:@"该会话已结束，表单已失效"];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)openUrl:(NSString *)urlString {
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

- (void)showImage:(YSF_NIMMessage *)message touchView:(UIView *)touchView {
    NSInteger imageViewIndex = touchView.tag;
    NSMutableArray *allGalleryItems = [NSMutableArray array];
    NSMutableArray *allLoadedImages = [self.sessionDataSource queryAllImageMessages];
    __block NSUInteger index = 0;
    __block NSUInteger currentIndex = 0;
    [allLoadedImages enumerateObjectsUsingBlock:^(YSF_NIMMessage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.messageType == YSF_NIMMessageTypeImage) {
            YSF_NIMImageObject *object = [obj messageObject];
            YSFGalleryItem *item = [[YSFGalleryItem alloc] init];
            item.thumbPath = [object thumbPath];
            item.imageURL = [object url];
            item.name = [object displayName];
            item.message = obj;
            item.indexAtMesaage = 0;
            [allGalleryItems addObject:item];
            if (message == obj) {
                index = currentIndex;
            }
            currentIndex++;
        } else {
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
                    item.imageURL = imageUrlString;
                    item.message = obj;
                    item.indexAtMesaage = idx;
                    [allGalleryItems addObject:item];
                    currentIndex++;
                }];
            }
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    YSFGalleryViewController *vc = [[YSFGalleryViewController alloc] initWithCurrentIndex:index
                                                                                 allItems:allGalleryItems
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

- (void)onTapPlayAudio:(YSFKitEvent *)event {
    BOOL isReceiverOrSpeaker = [[QYSDK sharedSDK].infoManager isRecevierOrSpeaker];
    [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:isReceiverOrSpeaker ? YSF_NIMAudioOutputDeviceReceiver : YSF_NIMAudioOutputDeviceSpeaker];
    if (isReceiverOrSpeaker) {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentPlayingReceiver];
    }
}

- (void)onTapFileMessage:(YSF_NIMMessage *)message {
    YSFFilePreviewViewController *vc = [[YSFFilePreviewViewController alloc] initWithFileMessage:message];
    [self.navigationController pushViewController:vc animated:YES];
}

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
    YSFEvaluationReasonView *evaluationResonView = [[YSFEvaluationReasonView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                                                          content:content
                                                                                         holdText:machineAttachment.evaluationGuide];
    evaluationResonView.delegate = self;
    evaluationResonView.data = message;
    evaluationResonView.completedBlock = ^{
        [weakSelf.sessionInputView inputBottomViewHeightToZero];
        [weakSelf.sessionInputView addKeyboardObserver];
    };
    [self.view.window addSubview:evaluationResonView];
    self.evaluationResonView = evaluationResonView;
}

- (UIView *)onQueryMessageContentViewCallback:(YSFGalleryItem *)item {
    NSArray *array = [self.tableView visibleCells];
    UIView *result = nil;
    for (UITableViewCell *cell in array) {
        if (![cell isKindOfClass:[YSFMessageCell class]]) {
            continue;
        }
        YSFMessageCell *messageCell = (YSFMessageCell *)cell;
        if (messageCell.model.message != item.message) {
            continue;
        }
        
        if ([messageCell.bubbleView isKindOfClass:[YSFRichTextContentView class]]) {
            YSFRichTextContentView *contentView = (YSFRichTextContentView *)messageCell.bubbleView;
            if (item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        } else if ([messageCell.bubbleView isKindOfClass:[YSFSessionMachineContentView class]]) {
            YSFSessionMachineContentView *contentView = (YSFSessionMachineContentView *)messageCell.bubbleView;
            if (item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        } else if ([messageCell.bubbleView isKindOfClass:[YSFStaticUnionContentView class]]) {
            YSFStaticUnionContentView *contentView = (YSFStaticUnionContentView *)messageCell.bubbleView;
            if (item.indexAtMesaage < contentView.imageViewsArray.count) {
                result = [contentView.imageViewsArray objectAtIndex:item.indexAtMesaage];
                break;
            }
        } else {
            result = messageCell.bubbleView;
            break;
        }
    }
    return result;
}

- (void)popEmailActionSheetWithStr:(NSString*)str {
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

- (void)onRetryMessage:(YSF_NIMMessage *)message {
    if (message.messageType == YSF_NIMMessageTypeVideo) {
        if (message.deliveryState == YSF_NIMMessageDeliveryStateFailed) {
            if (message.isReceivedMsg) {
                [[[YSF_NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                                       error:nil];
            } else {
                __weak typeof(self) weakSelf = self;
                YSFAlertController * alertController = [YSFAlertController actionSheetWithTitle:@"重新发送本条消息"];
                [alertController addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
                    [weakSelf onResendMessage:message];
                }]];
                [alertController addCancelActionWithHandler:nil];
                [alertController showWithSender:nil
                                 arrowDirection:UIPopoverArrowDirectionAny
                                     controller:self
                                       animated:YES
                                     completion:nil];
            }
        }
    } else {
        [self onResendMessage:message];
    }
}

- (void)onResendMessage:(YSF_NIMMessage *)message {
    if (message.isReceivedMsg) {
        [[[YSF_NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                               error:nil];
    } else {
        [self uiDeleteMessage:message];
        if (message.messageType == YSF_NIMMessageTypeAudio) {
            [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:message];
            YSF_NIMAudioObject *audioObject =  (YSF_NIMAudioObject *)message.messageObject;
            [self sendAudio:audioObject.path];
        } else {
            [[[YSF_NIMSDK sharedSDK] chatManager] resendMessage:message
                                                          error:nil];
        }
    }
}

#pragma mark YSFEvaluationReasonViewDelegate
- (void)evaluationReasonView:(YSFEvaluationReasonView *)view didConfirmWithText:(NSString *)text {
    if (!text || !view.data) {
        return;
    }
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
            if (weakSelf.evaluationResonView) {
                [weakSelf.evaluationResonView removeFromSuperview];
                weakSelf.evaluationResonView = nil;
            }
            YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject*)message.messageObject;
            YSFMachineResponse *machineAttachment = (YSFMachineResponse*)customObject.attachment;
            machineAttachment.evaluationContent = text;
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:weakSelf.session completion:nil];
            [weakSelf.view ysf_makeToast:@"感谢您的反馈" duration:1 position:YSFToastPositionCenter];
        } else {
            [weakSelf.view ysf_makeToast:@"提交失败，请稍后再试" duration:1 position:YSFToastPositionCenter];
        }
    }];
}

#pragma mark - YSFInputActionDelegate
- (void)onTextChanged:(id)sender {
    self.lastMessageContent = _sessionInputView.toolBar.inputTextView.text;
    [self sendInputtingMessage];
    [self sendSearchQuestion];
}

- (BOOL)onSendText:(NSString *)text {
    if (![self checkIfCanRequestStaffWithTip]) {
        return NO;
    }
    if (text) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //bug#16432，部分第三方输入法换行使用“\r”，该字符仅在Mac中表示换行和回车
        if ([text containsString:@"\r"]) {
            text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        }
    }
    if (text.length == 0) {
        [self showToast:@"不能发送空白消息"];
        self.sessionInputView.toolBar.inputTextView.text = @"";
        return NO;
    }
    YSF_NIMMessage *message = [YSFMessageMaker msgWithText:text];
    [self sendMessage:message];
    self.lastMessageContent = nil;
    [self clearQuickReplyView];
    return YES;
}

- (void)onSelectChartlet:(NSString *)chartletId catalog:(NSString *)catalogId {
    
}

- (void)onCancelRecording {
    [[YSF_NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording {
    [[YSF_NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording {
    if (![self checkIfCanRequestStaffWithTip]) {
        return;
    }
    [[YSF_NIMSDK sharedSDK].mediaManager recordAudioForDuration:60.f withDelegate:self];
}

- (void)sendInputtingMessage {
    YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    BOOL switchOpen = [YSFSystemConfig sharedInstance:_shopId].switchOpen;
    CGFloat sendingRate = [YSFSystemConfig sharedInstance:_shopId].sendingRate;
    if (session && session.humanOrMachine && switchOpen && _inputtingMessageTimer.isStopped && self.lastMessageContent) {
        __weak typeof(self) weakSelf = self;
        [_inputtingMessageTimer start:dispatch_get_main_queue() interval:sendingRate repeats:NO block:^{
            if (!weakSelf.inputtingMessageTimer.isStopped && weakSelf.lastMessageContent) {
                [weakSelf sendSendInputtingMessageRequest:weakSelf.lastMessageContent sessionId:session.sessionId sendingRate:sendingRate];
            }
        }];
    }
}

- (void)sendSendInputtingMessageRequest:(NSString *)lastMessageContent sessionId:(long long)sessionId sendingRate:(CGFloat)sendingRate {
    YSFSendInputtingMessageRequest *request = [[YSFSendInputtingMessageRequest alloc] init];
    request.sendingRate = sendingRate;
    request.sessionId = sessionId;
    request.content = lastMessageContent;
    request.endTime = [[NSDate date] timeIntervalSince1970];
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {}];
    self.lastMessageContent = nil;
}

- (void)sendSearchQuestion {
    if (![YSFSearchQuestionSetting sharedInstance:_shopId].switchOpen) {
        return;
    }
    if (_lastMessageContent.length > 0 && _lastMessageContent.length <= 10) {
        YSFServiceSession *session = [[[QYSDK sharedSDK] sessionManager] getOnlineOrWaitingSession:_shopId];
        CGFloat sendingRate = [YSFSearchQuestionSetting sharedInstance:_shopId].sendingRate;
        if (session && _inputAssociateTimer.isStopped && self.lastMessageContent) {
            __weak typeof(self) weakSelf = self;
            [_inputAssociateTimer start:dispatch_get_main_queue() interval:sendingRate repeats:NO block:^{
                if (!weakSelf.inputAssociateTimer.isStopped && weakSelf.lastMessageContent) {
                    [weakSelf sendSearchQuestionRequest:weakSelf.lastMessageContent sessionId:session.sessionId sendingRate:sendingRate];
                }
            }];
        }
    } else {
        [self clearQuickReplyView];
    }
}

- (void)sendSearchQuestionRequest:(NSString *)lastMessageContent sessionId:(long long)sessionId sendingRate:(CGFloat)sendingRate {
    YSFSendSearchQuestionRequest *request = [[YSFSendSearchQuestionRequest alloc] init];
    request.sessionId = sessionId;
    request.content = lastMessageContent;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:_shopId completion:^(NSError *error) {}];
    self.lastMessageContent = nil;
}

- (void)onMediaPicturePressed {
    if (![self checkIfCanRequestStaffWithTip]) {
        return;
    }
    
    [self.sessionInputView.toolBar.inputTextView resignFirstResponder];
    [self showSelectImageAlertController];
}

#pragma mark - 长按操作
- (void)onLongPressCell:(YSF_NIMMessage *)message inView:(UIView *)view {
    NSArray *items = [self menusItems:message];
    if ([items count]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        _messageTouchView = view;
        
        if ([self.sessionInputView.toolBar.inputTextView isFirstResponder]) {
            self.sessionInputView.toolBar.inputTextView.overrideNextResponder = self;
        } else {
            [self becomeFirstResponder];
        }
        
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)menusItems:(YSF_NIMMessage *)message {
    NSMutableArray *items = [NSMutableArray array];
    if (message.messageType == YSF_NIMMessageTypeAudio) {
        NSString *string;
        if ([[QYSDK sharedSDK].infoManager isRecevierOrSpeaker]) {
            string = @"扬声器模式";
        } else {
            string = @"听筒模式";
        }
        [items addObject:[[UIMenuItem alloc] initWithTitle:string action:@selector(changePlayAudioMode:)]];
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字" action:@selector(transAudioToText:)]];
    } else if (message.messageType == YSF_NIMMessageTypeText && message.text.length > 0) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyTextOrImage:)]];
    } else if (message.messageType == YSF_NIMMessageTypeImage) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyTextOrImage:)]];
    } else if (message.messageType == YSF_NIMMessageTypeVideo) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"静音" action:@selector(playVideoWithSoundOff:)]];
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"保存" action:@selector(saveVideoToSystemLibrary:)]];
    } else if (message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]
            || [customObject.attachment isKindOfClass:[QYCommodityInfo class]]) {
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyTextOrImage:)]];
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMsg:)]];
        } else if ([customObject.attachment isKindOfClass:[YSFRichText class]]) {
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyTextOrImage:)]];
        }
    } else {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMsg:)]];
    }
    return items;
}

- (YSF_NIMMessage *)messageForMenu {
    return _messageForMenu;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)changePlayAudioMode:(id)sender {
    BOOL isReceiverOrSpeaker = [[QYSDK sharedSDK].infoManager isRecevierOrSpeaker];
    [[QYSDK sharedSDK].infoManager setRecevierOrSpeaker:!isReceiverOrSpeaker];
    if (isReceiverOrSpeaker) {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentModeSpeaker];
    } else {
        [_recordTipView setReceiverOrSpeaker:YSF_TipTypeCurrentModeReceiver];
    }
}

- (void)transAudioToText:(id)sender {
    YSF_NIMMessage *message = [self messageForMenu];
    if (message.messageType == YSF_NIMMessageTypeAudio) {
        YSF_NIMAudioObject *audioObject = (YSF_NIMAudioObject *)message.messageObject;
        YSF_NIMAudioToTextOption *option = [YSF_NIMAudioToTextOption new];
        option.url = audioObject.url;
        option.filepath = audioObject.path;
        YSFTransAudioToTextLoadingViewController *vc = [[YSFTransAudioToTextLoadingViewController alloc] initWithAudioToTextOption:message];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)copyTextOrImage:(id)sender {
    YSF_NIMMessage *message = [self messageForMenu];
    if (message.messageType == YSF_NIMMessageTypeText) {
        if (message.text.length) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(message.text)];
        }
    } else if (message.messageType == YSF_NIMMessageTypeImage) {
        YSF_NIMImageObject *imageObject = (YSF_NIMImageObject *)message.messageObject;
        if (imageObject.thumbPath.length) {
            UIImage * image = [UIImage imageWithContentsOfFile:imageObject.thumbPath];
            if (image) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setImage:image];
            }
        }
    } else if (message.messageType == YSF_NIMMessageTypeCustom) {
        YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObject.attachment isKindOfClass:[YSFMachineResponse class]]) {
            YSFMachineResponse *machineResponse = (YSFMachineResponse *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(machineResponse.rawStringForCopy)];
        } else if ([customObject.attachment isKindOfClass:[YSFKFBypassNotification class]]) {
            YSFKFBypassNotification *notification = (YSFKFBypassNotification *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(notification.rawStringForCopy)];
        } else if ([customObject.attachment isKindOfClass:[YSFReportQuestion class]]) {
            YSFReportQuestion *notification = (YSFReportQuestion *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(notification.question)];
        } else if ([customObject.attachment isKindOfClass:[QYCommodityInfo class]]) {
            QYCommodityInfo *commodityInfoShow = (QYCommodityInfo *)customObject.attachment;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(commodityInfoShow.urlString)];
        } else if ([customObject.attachment isKindOfClass:[YSFRichText class]]) {
            YSFRichText *richText = (YSFRichText *)customObject.attachment;
            NSString *copyText = nil;
            if (richText.displayContent.length) {
                copyText = richText.displayContent;
                NSString *lastChar = [copyText substringWithRange:NSMakeRange((copyText.length - 1), 1)];
                if ([lastChar isEqualToString:@"\n"]) {
                    copyText = [copyText substringWithRange:NSMakeRange(0, (copyText.length - 1))];
                }
            } else if (richText.content.length) {
                copyText = richText.content;
            }
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:YSFStrParam(copyText)];
        }
    }
}

- (void)deleteMsg:(id)sender {
    YSF_NIMMessage *message = [self messageForMenu];
    YSFMessageModel *model = [self makeModel:message];
    [self.layoutManager deleteCellAtIndexs:[self.sessionDataSource deleteMessageModel:model]];
    [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:model.message];
    //文件消息删除的同时文件缓存也要删除
    if (message.messageType == YSF_NIMMessageTypeFile) {
        YSF_NIMFileObject *fileObject = (YSF_NIMFileObject *)message.messageObject;
        [[NSFileManager defaultManager] removeItemAtPath:fileObject.path error:nil];
    }
}

#pragma mark - YSF_NIMMediaManagerDelgate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (filePath && error == nil) {
        _sessionInputView.recording = YES;
    } else {
        [self onRecordFailed:error];
    }
}

- (void)sendAudio:(NSString *)filePath {
    YSF_NIMMessage *messageAudio = [YSFMessageMaker msgWithAudio:filePath];
    YSFServiceSession *onlineSession = [[[QYSDK sharedSDK] sessionManager] getOnlineSession:_shopId];
    if (onlineSession && !onlineSession.humanOrMachine) {
        YSF_NIMSession *session = [YSF_NIMSession session:_shopId type:YSF_NIMSessionTypeYSF];
        messageAudio.from = [[YSF_NIMSDK sharedSDK].loginManager currentAccount];
        NSError *error = [messageAudio prepareForSend];
        if (error) {
            return;
        }
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                          message:messageAudio
                                                       forSession:session
                                                   addUnreadCount:NO
                                                       completion:nil];
        messageAudio.isDeliveried = NO;
        [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES
                                                            message:messageAudio
                                                         forSession:_session
                                                         completion:nil];
        [[KFAudioToTextHandler sharedInstance] addMessage:messageAudio.from messageId:messageAudio.messageId];
        __weak typeof(self) weakSelf = self;
        [[[YSF_NIMSDK sharedSDK] resourceManager] upload:filePath progress:nil completion:^(NSString *urlString, NSError *error) {
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
                                                                 } else {
                                                                     messageAudio.isDeliveried = NO;
                                                                     [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES
                                                                                                                         message:messageAudio
                                                                                                                      forSession:weakSelf.session
                                                                                                                      completion:nil];
                                                                     [self showToast:@"语音转文字失败"];
                                                                 }
                                                             }];
        }];
    } else {
        [self sendMessage:messageAudio];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if (!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendAudio:filePath];
        } else{
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


#pragma mark - 录音相关
- (void)onRecordFailed:(NSError *)error {
    
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath {
    return YES;
}

- (void)showRecordFileNotSendReason {
    
}


#pragma mark - 图片/视频
- (void)showSelectImageAlertController {
    __weak typeof(self) weakSelf = self;
    YSFAlertController * alertController = [YSFAlertController actionSheetWithTitle:nil];
    //相册：目前使用系统相册界面，无法多选
    [alertController addAction:[YSFAlertAction actionWithTitle:@"选择本地图片" handler:^(YSFAlertAction * _Nonnull action) {
        [weakSelf mediaPicturePressed];
    }]];
    //拍照：目前使用系统照相机界面，无法定制化
    [alertController addAction:[YSFAlertAction actionWithTitle:@"拍照" handler:^(YSFAlertAction * _Nonnull action) {
        [weakSelf mediaShootPressed];
    }]];
    //视频：使用AVCapture相关库进行界面包装
    [alertController addAction:[YSFAlertAction actionWithTitle:@"视频" handler:^(YSFAlertAction * _Nonnull action) {
        [weakSelf showCameraViewController];
    }]];
    [alertController addCancelActionWithHandler:nil];
    [alertController showWithSender:_sessionInputView.toolBar.imageButton
                     arrowDirection:UIPopoverArrowDirectionAny
                         controller:self
                           animated:YES
                         completion:nil];
}

- (void)mediaPicturePressed {
    self.mode = YSFImagePickerModePicture;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (UIImagePickerController *)cameraInit {
    if (![self checkAvailableForCamera]) {
        return nil;
    }
    if (![self checkAuthorizationStatusForCamera]) {
        return nil;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    return imagePicker;
}

- (void)mediaShootPressed {
    UIImagePickerController *imagePicker = [self cameraInit];
    if (imagePicker) {
        self.mode = YSFImagePickerModeShoot;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showCameraViewController {
    if (![self checkAvailableForCamera]) {
        return;
    }
    if (![self checkAuthorizationStatusForCamera]) {
        return;
    }
    if (![self checkAuthorizationStatusForAudio]) {
        return;
    }
    self.mode = YSFImagePickerModeVideo;
    YSFCameraViewController *cameraVC = [[YSFCameraViewController alloc] init];
    cameraVC.videoDataPath = [[[QYSDK sharedSDK] pathManager] sdkVideoPath];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (void)onPasteImage:(UIImage *)image {
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

- (BOOL)checkAvailableForCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"检测不到相机设备"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (BOOL)checkAuthorizationStatusForCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"没有相机权限"
                                    message:@"请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机。"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (BOOL)checkAuthorizationStatusForAudio {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"没有麦克风权限"
                                    message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许访问你的麦克风。"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {

    } else {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        __weak typeof(self) weakSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            switch (weakSelf.mode) {
                case YSFImagePickerModePicture: {
                    [weakSelf sendMessage:[YSFMessageMaker msgWithImage:orgImage]];
                    break;
                }
                case YSFImagePickerModeShoot: {
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickImageCompeletedWithImages:(NSArray*)images {
    for (UIImage* image in images) {
        [self sendMessage:[YSFMessageMaker msgWithImage:image]];
    }
}

- (void)pickImageCanceled {
    
}

- (void)sendVideoMessage:(NSURL *)url {
    [self sendMessage:[YSFMessageMaker msgWithVideo:url.path]];
    [[YSFVideoDataManager sharedManager] saveVideoToSystemLibrary:url.path completion:nil];
}

- (void)playVideoWithSoundOff:(id)sender {
    YSF_NIMMessage *message = [self messageForMenu];
    if (YSF_NIMMessageTypeVideo == message.messageType) {
        YSFVideoPlayerViewController *playerVC = [[YSFVideoPlayerViewController alloc] init];
        playerVC.transitioningDelegate = self;
        playerVC.message = message;
        playerVC.soundOff = YES;
        [self presentViewController:playerVC animated:YES completion:nil];
    }
}

- (void)saveVideoToSystemLibrary:(id)sender {
    YSF_NIMMessage *message = [self messageForMenu];
    if (YSF_NIMMessageTypeVideo == message.messageType) {
        YSF_NIMVideoObject *videoObject = (YSF_NIMVideoObject *)message.messageObject;
        if (videoObject.path.length) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:videoObject.path]) {
                [[YSFVideoDataManager sharedManager] saveVideoToSystemLibrary:videoObject.path completion:^(BOOL success) {}];
            }
        }
    }
}

- (void)onTapPlayVideo:(YSF_NIMMessage *)message touchView:(UIView *)touchView {
    if (YSF_NIMMessageTypeVideo == message.messageType) {
        _messageTouchView = touchView;
        YSFVideoPlayerViewController *playerVC = [[YSFVideoPlayerViewController alloc] init];
        playerVC.transitioningDelegate = self;
        playerVC.message = message;
        playerVC.soundOff = NO;
        [self presentViewController:playerVC animated:YES completion:nil];
    }
}

#pragma mark - kKFInputViewInputTypeChanged
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

#pragma mark - YSFReachabilityChangedNotification
- (void)onNetworkChanged:(NSNotification *)notification {
    [_tipView setSessionTip:[_reachability isReachable] ? YSFSessionTipNetworkOK : YSFSessionTipNetworkError];
}

#pragma mark - AVAudioSessionRouteChangeNotification
- (void)onAVSessionChanged:(NSNotification *)notification {
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

#pragma mark - UIMenuControllerDidHideMenuNotification
- (void)menuDidHide:(NSNotification *)notification {
    self.sessionInputView.toolBar.inputTextView.overrideNextResponder = nil;
    [UIMenuController sharedMenuController].menuItems = nil;
}

#pragma mark - UIApplicationWillResignActiveNotification
- (void)willResignActive:(NSNotification *)notification {
    YSFLogApp(@"notification: %@", notification);
    [self cancelRecordAudio];
}

#pragma mark - UIApplicationDidEnterBackgroundNotification
- (void)didEnterBackground:(NSNotification *)notification {
    YSFLogApp(@"notification: %@", notification);
    [self cancelRecordAudio];
}

#pragma mark - 其他
- (void)showToast:(NSString *)toast {
    if (toast.length) {
        UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
        [topWindow ysf_makeToast:toast duration:2 position:YSFToastPositionCenter];
    }
}

- (void)cancelRecordAudio {
    [_sessionInputView setRecordPhase:AudioRecordPhaseCancelling];
    [_sessionInputView setRecordPhase:AudioRecordPhaseEnd];
    [[YSF_NIMSDK sharedSDK].mediaManager stopPlay];
}

- (void)showBotCustomViewController:(YSFBotCustomObject *)botCustomObject {
    if ([QYCustomActionConfig sharedInstance].showBotCustomInfoBlock) {
        [QYCustomActionConfig sharedInstance].showBotCustomInfoBlock(botCustomObject.customObject);
    }
}

#pragma mark - 旋转处理 (iOS7)
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.sessionDataSource cleanCache];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
    [_sessionInputView setRecordPhase:AudioRecordPhaseCancelling];
    [_sessionInputView setRecordPhase:AudioRecordPhaseEnd];
}

#pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source {
    if (_messageTouchView && [presented isKindOfClass:[YSFVideoPlayerViewController class]]) {
        return [self makeAnimationForPresent:YES touchView:_messageTouchView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (_messageTouchView && [dismissed isKindOfClass:[YSFVideoPlayerViewController class]]) {
        return [self makeAnimationForPresent:NO touchView:_messageTouchView];
    }
    return nil;
}

- (YSFViewControllerTransitionAnimation *)makeAnimationForPresent:(BOOL)present touchView:(UIView *)touchView {
    YSFViewControllerTransitionAnimation *animation = [[YSFViewControllerTransitionAnimation alloc] init];
    animation.present = present;
    animation.originFrame = [touchView.superview convertRect:touchView.frame toView:self.view];
    return animation;
}

@end

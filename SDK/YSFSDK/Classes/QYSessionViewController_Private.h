//
//  YSFSessionViewController.h
//  YSFSDK
//
//  Created by amao on 8/25/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "QYPOPSessionViewController.h"
#import "YSFSessionConfig.h"
#import "YSFInputProtocol.h"
#import "YSFMessageCellProtocol.h"
#import "YSFSessionMsgDatasource.h"
#import "YSFInputView.h"
#import "YSFInputTextView.h"
#import "YSFSessionViewLayoutManager.h"
#import "YSFMessageCellProtocol.h"
#import "YSFMessageModel.h"
#import "YSFKitUtil.h"
#import "YSFCustomLeftBarView.h"
#import "YSFBadgeView.h"
#import "UITableView+YSFKit.h"
#import "YSFMessageMaker.h"
#import "YSFDefaultValueMaker.h"
#import "YSFTimestampModel.h"
#import "YSFMessageCellMaker.h"
#import "YSFSessionConfigImp.h"
#import "QYSDK_Private.h"
#import "YSFSessionTipView.h"
#import "YSFRecordTipView.h"

@class YSFReachability;
typedef void (^ChangeHumanOrRobotBlock)(BOOL humanOrRobot);
typedef void (^ChangeEvaluationEnabledBlock)(BOOL evaluationEnabled);
typedef void (^OnEvaluateBlock)(long long sessionId, NSString *evaluationMessageInvite, NSString *evaluationMessageThanks);


@interface QYSessionViewController ()
<UITableViewDataSource,
UITableViewDelegate,
YSF_NIMChatManagerDelegate,
YSF_NIMConversationManagerDelegate,
YSF_NIMLoginManagerDelegate,
YSF_NIMMediaManagerDelgate,
YSFMessageCellDelegate,
YSFInputActionDelegate,
YSFMessageCellDelegate,
NIMSessionMsgDatasourceDelegate,
YSFSessionProtocol,
YSFSessionTipViewDelegate>

@property (nonatomic,strong)                UITableView *tableView;
@property (nonatomic,strong)                UIImageView *sessionBackground;
@property (nonatomic, strong,readonly)      UIRefreshControl *refreshControl;

@property (nonatomic,strong)                YSFInputView *sessionInputView;
@property (nonatomic,strong)                YSFSessionViewLayoutManager *layoutManager;
@property (nonatomic,strong)                YSFSessionMsgDatasource *sessionDatasource;
@property (nonatomic,strong)                YSF_NIMMessage *messageForMenu;
@property (nonatomic,strong,readonly)       YSF_NIMSession *session;
@property (nonatomic,strong)                YSFSessionConfigImp *configImp;
@property (nonatomic,strong)                YSFSessionTipView *tipView;
@property (nonatomic,strong)                YSFRecordTipView *recordTipView;
@property (nonatomic,strong)                YSFReachability *reachability;
@property (nonatomic,strong)                YSFCustomLeftBarView *leftBarView;
@property (nonatomic,copy)                  ChangeHumanOrRobotBlock changeHumanOrRobotBlock;
@property (nonatomic,copy)                  ChangeEvaluationEnabledBlock changeEvaluationEnabledBlock;
@property (nonatomic,copy)                  OnEvaluateBlock onEvaluateBlock;


- (NSArray *)menusItems:(YSF_NIMMessage *)message;

- (id<YSFSessionConfig>)sessionConfig;

- (void)sendMessage:(YSF_NIMMessage *)message;

- (void)onRecordFailed:(NSError *)error;

- (BOOL)recordFileCanBeSend:(NSString *)filepath;

- (void)showRecordFileNotSendReason;

- (void)uiDeleteMessage:(YSF_NIMMessage *)message;


- (void)uiUpdateMessage:(YSF_NIMMessage *)message;

- (void)sendCloseSessionCustomMessage:(BOOL)quitWaitingOrCloseSession
                    completetionBlock:(void (^)(BOOL isSuccess))completetionBlock;

- (void)sendEvaluationRequest:(NSUInteger)score remarks:(NSString *)remarks
                       tagIds:(NSArray *)tagIds sessionId:(long long)sessionId;

@end

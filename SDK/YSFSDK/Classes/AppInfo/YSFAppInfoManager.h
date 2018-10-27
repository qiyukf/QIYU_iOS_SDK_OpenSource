//
//  YSFAppInfoManager.h
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAccountInfo.h"
#import "QYUserInfo.h"
#import "YSFServiceSession.h"
#import "QYSDK_Private.h"

#define YSFAppInfoKey       @"app_info"
#define YSFAppSettingKey    @"app_setting"
#define YSFCurrentForeignUserIdKey @"current_foreign_userid"
#define YSFCurrentUserInfoKey @"current_user_info"
#define YSFTrackHistoryDataKey @"track_history_data"
#define YSFTrackHistoryDataSendKey @"track_history_data_send"
#define YSFDeviceInfoKey    @"device_info"
#define YSFCachedTextKey    @"cached_text_2.0"
#define YSFStaffIdIconUrl   @"staffid_iconrul"
#define YSFShopInfoKey      @"shopInfo"
#define YSFUnreadPushMessageSessionId @"unreadPushMessageSessionId"

//Evaluation
#define YSFEvaluation_2                     @"evalution_2.0"
#define YSFEvaluation_3                     @"evalution_3.0"
#define YSFEvaluationRecentData             @"recent_data"
#define YSFEvaluationHistoryData            @"history_data"
//recent data:仅保存最近会话评价数据
#define YSFEvaluationSessionId              @"session_id"
#define YSFEvaluationSessionStatus          @"session_status"
#define YSFEvaluationSessionTimes           @"session_times"
#define YSFEvaluationAutoPopup              @"evaluation_auto"
#define YSFEvaluationAutoPopupSessionId     @"session_id_auto"
#define YSFEvaluationAutoPopupMessageID     @"message_id_auto"
//history data:保存了多个会话的评价数据
#define YSFEvaluationMessageID              @"message_id"
#define YSFEvaluationData                   @"evaluation_data"
#define YSFEvaluationInviteText             @"invite_text"
#define YSFEvaluationThanksText             @"thanks_text"
#define YSFEvaluationSpecialThanksText      @"special_thanks_text"
#define YSFEvaluationModifyEnable           @"modify_enable"
#define YSFEvaluationModifyTime             @"modify_time"
#define YSFEvaluationModifyLimit            @"modify_limit"
#define YSFEvaluationResultData             @"evaluation_result"


@protocol YSFAppInfoManagerDelegate <NSObject>

- (void)didCreateAccountSuccessfully;

@end


@interface YSFAppInfoManager : NSObject

- (NSString *)versionNumber;
- (NSString *)version;

- (NSString *)cachedText:(NSString *)shopId;
- (void)setCachedText:(NSString *)cachedText shopId:(NSString *)shopId;

@property (nonatomic,strong,readonly)    YSFAccountInfo *accountInfo;

@property (nonatomic, weak) id<YSFAppInfoManagerDelegate> delegate;

- (void)initSessionViewControllerInfo;

- (NSString *)currentUserId;

- (NSString *)currentForeignUserId;

- (void)checkAppInfo;

- (NSString *)appDeviceId;

- (void)trackHistory:(NSString *)title enterOrOut:(BOOL)enterOrOut key:(NSString *)key;

- (void)trackHistory:(NSString *)title description:(NSDictionary *)description key:(NSString *)key;

- (void)setUserInfo:(QYUserInfo *)userInfo authTokenVerificationResultBlock:(QYCompletionWithResultBlock)block;

- (BOOL)isRecevierOrSpeaker;

- (void)setRecevierOrSpeaker:(BOOL)recevierOrSpeaker;

- (void)logout;

- (NSDictionary *)dictByKey:(NSString *)key;
- (NSArray *)arrayByKey:(NSString *)key;

- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key;
- (void)saveArray:(NSArray *)array forKey:(NSString *)key;

@end

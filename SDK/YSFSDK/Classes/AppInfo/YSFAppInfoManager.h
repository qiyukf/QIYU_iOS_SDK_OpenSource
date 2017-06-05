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
#define YSFDeviceInfoKey    @"device_info"
#define YSFCachedTextKey    @"cached_text"
#define YSFStaffIdIconUrl   @"staffid_iconrul"
#define YSFShopInfoKey      @"shopInfo"
#define YSFUnreadPushMessageSessionId @"unreadPushMessageSessionId"

#define YSFEvalution        @"evalution_2.0"
#define YSFCurrentSessionId @"current_session_id"
#define YSFSessionTimes     @"session_times"
#define YSFEvaluationData   @"evaluation_data"
#define YSFSessionStatus    @"session_status"


@protocol YSFAppInfoManagerDelegate <NSObject>

- (void)didCreateAccountSuccessfully;

@end


@interface YSFAppInfoManager : NSObject
@property (nonatomic,strong)    NSString *cachedText;

@property (nonatomic,strong,readonly)    YSFAccountInfo *accountInfo;

@property (nonatomic, weak) id<YSFAppInfoManagerDelegate> delegate;

- (void)initSessionViewControllerInfo;

- (NSString *)currentUserId;

- (NSString *)currentForeignUserId;

- (void)checkAppInfo;

- (NSString *)appDeviceId;

- (void)setUserInfo:(QYUserInfo *)userInfo authTokenVerificationResultBlock:(QYCompletionWithResultBlock)block;

- (BOOL)isRecevierOrSpeaker;

- (void)setRecevierOrSpeaker:(BOOL)recevierOrSpeaker;

- (void)logout;

- (NSDictionary *)dictByKey:(NSString *)key;
- (NSArray *)arrayByKey:(NSString *)key;

- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key;
- (void)saveArray:(NSArray *)array forKey:(NSString *)key;

@end

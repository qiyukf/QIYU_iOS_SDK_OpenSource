//
//  QYSDK.h
//  QYSDK
//
//  Created by towik on 12/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "QYSDK.h"
#import "YSFAppInfoManager.h"
#import "YSFPathManager.h"
#import "YSFSessionManager.h"
#import "YSFServerSetting.h"

@class YSFAppInfoManager;
@class YSFConversationManager;
@class QYCustomUIConfig;

typedef NS_ENUM(NSUInteger, YSFUseServerSetting) {
    YSFUseServerSettingOnline = 0,
    YSFUseServerSettingTest,
    YSFUseServerSettingPre,
    YSFUseServerSettingDev,
};

@interface QYSDK ()

@property (nonatomic,assign)    YSFUseServerSetting   serverSetting;

@property (nonatomic,copy,readonly)    NSString   *serverAddress;

@property (nonatomic,strong)    YSFAppInfoManager   *infoManager;

@property (nonatomic,strong)    YSFSessionManager   *sessionManager;

@property (nonatomic,strong)    YSFPathManager      *pathManager;

@property (nonatomic,strong)    YSFConversationManager  *sdkConversationManager;

@property (nonatomic,copy)    QYPushMessageBlock   pushMessageBlock;

@property (nonatomic,copy)    NSString   *authToken;

+ (void)cleanMessageCache;

- (NSString *)deviceId;

- (void)cleanAuthToken;


@end

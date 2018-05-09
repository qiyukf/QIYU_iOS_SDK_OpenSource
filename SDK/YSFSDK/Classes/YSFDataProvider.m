//
//  YSFDataProvider.m
//  YSFSDK
//
//  Created by amao on 8/25/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFDataProvider.h"
#import "QYCustomUIConfig.h"
#import "QYSDK_Private.h"
#import "YSF_NIMMessage+YSF.h"

@implementation YSFDataProvider
- (YSFSessionUserInfo *)infoByCustomer:(YSF_NIMMessage *)message
{
    YSFSessionUserInfo *info = [[YSFSessionUserInfo alloc] init];
    info.avatarImage = [[QYCustomUIConfig sharedInstance] customerHeadImage];
    info.avatarUrlString = [[QYCustomUIConfig sharedInstance] customerHeadImageUrl];

    return info;
}

- (YSFSessionUserInfo *)infoByService:(YSF_NIMMessage *)message
{
    YSFSessionUserInfo *info = [[YSFSessionUserInfo alloc] init];
    info.avatarImage = [[QYCustomUIConfig sharedInstance] serviceHeadImage];
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    NSString *messageFrom = message.from;
    if (message.isPushMessageType) {
        info.avatarUrlString = message.staffHeadImageUrl;
    }
    else
    {
        info.avatarUrlString = [sessionManager queryIconUrlFromStaffId:messageFrom];
        if (info.avatarUrlString.length == 0) {
            info.avatarUrlString = [[QYCustomUIConfig sharedInstance] serviceHeadImageUrl];
        }
    }

    return info;
}

@end

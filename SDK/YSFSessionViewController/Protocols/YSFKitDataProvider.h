//
//  YSFKitDataProvider
//  YSFKit
//
//  Created by amao on 8/13/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//


@class YSF_NIMSession;
@class YSFSessionUserInfo;

@protocol YSFKitDataProvider <NSObject>

@optional

- (YSFSessionUserInfo *)infoByCustomer:(YSF_NIMMessage *)message;

- (YSFSessionUserInfo *)infoByService:(YSF_NIMMessage *)message;


@end

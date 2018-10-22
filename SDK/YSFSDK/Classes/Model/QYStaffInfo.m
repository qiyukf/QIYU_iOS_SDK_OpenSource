//
//  QYStaffInfo.m
//  YSFSDK
//
//  Created by liaosipei on 2018/10/12.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "QYStaffInfo.h"

@implementation QYStaffInfo

- (void)setStaffId:(NSString *)staffId {
    if (staffId.length > 20) {
        _staffId = [staffId substringToIndex:20];
    } else {
        _staffId = staffId;
    }
}

- (void)setNickName:(NSString *)nickName {
    if (nickName.length > 20) {
        _nickName = [nickName substringToIndex:20];
    } else {
        _nickName = nickName;
    }
}

- (void)setAccessTip:(NSString *)accessTip {
    if (accessTip.length > 50) {
        _accessTip = [accessTip substringToIndex:50];
    } else {
        _accessTip = accessTip;
    }
}

@end

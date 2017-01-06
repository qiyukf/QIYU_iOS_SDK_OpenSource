//
//  YSFMessageCellProtocol.h
//  YSFKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"


@class YSFMessageModel;
@class YSF_NIMMessage;
@class YSFKitEvent;
@protocol YSFMessageCellDelegate <NSObject>

@optional

- (void)onTapCell:(YSFKitEvent *)event;

- (void)onLongPressCell:(YSF_NIMMessage *)message
                 inView:(UIView *)view;

- (void)onRetryMessage:(YSF_NIMMessage *)message;

- (void)onTapAvatar:(NSString *)userId;

- (void)onTapLinkData:(id)linkData;

@end

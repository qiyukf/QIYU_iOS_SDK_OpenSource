//
//  YSF_NIMUtil.h
//  YSFKit
//
//  Created by chris on 15/8/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//


@interface YSFKitUtil : NSObject

+ (NSString *)showNick:(NSString*)uid inSession:(YSF_NIMSession*)session;

+ (NSString *)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail;

+ (NSString *)formatedMessage:(YSF_NIMMessage *)message;

@end

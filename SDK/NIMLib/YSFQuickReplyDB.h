//
//  YSFQuickReplyDB.h
//  NIMLib
//
//  Created by Jacky Yu on 2018/3/6.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSFQuickReply;

typedef void(^YSFSearchQuickReplyBlock)(NSArray<YSFQuickReply*> *quickReplys);

@interface YSFQuickReplyDB : NSObject

+ (instancetype)sharedDB;
- (instancetype)init NS_UNAVAILABLE;

- (void)saveQuickReplys:(NSArray<YSFQuickReply*>*)quickReplys;
- (void)saveQuickReply:(YSFQuickReply *)quickReply;
- (void)removeQuickReply:(YSFQuickReply *)quickReply;
- (void)removeAllQuickReply;
- (void)searchQuickReplyWithText:(NSString*)text result:(YSFSearchQuickReplyBlock)block;

@end

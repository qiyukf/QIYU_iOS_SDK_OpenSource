//
//  NIMSessionMsgDatasource.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFSessionMsgDatasource.h"
#import "UIScrollView+YSFKit.h"
#import "YSFMessageModel.h"
#import "YSFTimestampModel.h"
#import "YSFRichText.h"
#import "YSFMachineResponse.h"
#import "YSFStaticUnion.h"
#import "YSFSubmittedBotForm.h"


@implementation YSFSessionMsgDatasource


- (instancetype)initWithSession:(YSF_NIMSession*)session
               showTimeInterval:(NSTimeInterval)timeInterval
                          limit:(NSInteger)limit
{
    if (self = [self init]) {
        _currentSession    = session;
        _messageLimit      = limit;
        _showTimeInterval  = timeInterval;
        _firstTimeInterval = 0;
        _lastTimeInterval  = 0;
    }
    return self;
}


- (void)resetMessages
{
    self.modelArray        = [NSMutableArray array];
    self.msgIdDict         = [NSMutableDictionary dictionary];
    self.firstTimeInterval = 0;
    self.lastTimeInterval  = 0;

    NSArray *messages = [[[YSF_NIMSDK sharedSDK] conversationManager] messagesInSession:_currentSession
                                                                               message:nil
                                                                                 limit:_messageLimit];
    [self appendMessages:messages];
    self.firstTimeInterval = [messages.firstObject timestamp];
    self.lastTimeInterval  = [messages.lastObject timestamp];
    if ([self.delegate respondsToSelector:@selector(messageDataIsReady)]) {
        [self.delegate messageDataIsReady];
    }
}

- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index,  NSError *error))handler
{
    __block YSFMessageModel *currentOldestMsg = nil;
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]]) {
            currentOldestMsg = (YSFMessageModel*)obj;
            *stop = YES;
        }
    }];
    NSInteger index = 0;
    if (currentOldestMsg) {
        NSArray *messages = [[[YSF_NIMSDK sharedSDK] conversationManager] messagesInSession:_currentSession
                                                                                    message:currentOldestMsg.message
                                                                                      limit:self.messageLimit];
        index = [self insertMessages:messages];
    }
    if (handler) {
        ysf_dispatch_async_main(^{
            handler(index,nil);
        });
    }
}

/**
 *  从头插入消息
 *
 *  @param messages 消息
 *
 *  @return 插入后table要滑动到的位置
 */
- (NSInteger)insertMessages:(NSArray *)messages
{
    NSInteger count = self.modelArray.count;
    for (YSF_NIMMessage *message in messages.reverseObjectEnumerator.allObjects) {
        [self insertMessage:message];
    }
    return self.modelArray.count - count;
}

- (NSInteger)insertMessagesAt:(NSInteger)postion messages:(NSArray *)messages
{
    NSInteger count = self.modelArray.count;
    for (YSF_NIMMessage *message in messages.reverseObjectEnumerator.allObjects) {
        [self insertMessageAt:postion message:message];
    }
    return self.modelArray.count - count;
}

/**
 *  从后插入消息
 *
 *  @param messages 消息集合
 *
 *  @return 插入的消息的index
 */
- (NSArray *)appendMessages:(NSArray *)messages
{
    if (!messages.count) {
        return @[];
    }
    NSInteger count = self.modelArray.count;
    for (YSF_NIMMessage *message in messages) {
        [self appendMessage:message];
    }
    NSMutableArray *append = [[NSMutableArray alloc] init];
    for (NSInteger i = count; i < self.modelArray.count; i++) {
        [append addObject:@(i)];
    }
    return append;
}


- (NSInteger)indexAtModelArray:(YSFMessageModel *)model
{
    __block NSInteger index = -1;
    if (![_msgIdDict objectForKey:model.message.messageId]) {
        return index;
    }
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]]) {
            if ([model isEqual:obj]) {
                index = idx;
                *stop = YES;
            }
        }
    }];
    return index;
}

#pragma mark - msg
- (NSInteger)msgCount
{
    return [_modelArray count];
}

- (NSArray*)addMessages:(NSArray*)messages
{
    return [self appendMessages:messages];
}

- (BOOL)modelIsExist:(YSFMessageModel *)model
{
    return [_msgIdDict objectForKey:model.message.messageId] != nil;
}

- (NSArray*)deleteMessageModel:(YSFMessageModel *)msgModel
{
    NSMutableArray *dels = [NSMutableArray array];
    NSInteger delTimeIndex = -1;
    NSInteger delMsgIndex = [_modelArray indexOfObject:msgModel];
    if (delMsgIndex > 0) {
        BOOL delMsgIsSingle = (delMsgIndex == _modelArray.count-1 || [_modelArray[delMsgIndex+1] isKindOfClass:[YSFTimestampModel class]]);
        if ([_modelArray[delMsgIndex-1] isKindOfClass:[YSFTimestampModel class]] && delMsgIsSingle) {
            delTimeIndex = delMsgIndex-1;
            [_modelArray removeObjectAtIndex:delTimeIndex];
            [dels addObject:@(delTimeIndex)];
        }
    }
    if (delMsgIndex > -1) {
        [_modelArray removeObject:msgModel];
        [_msgIdDict removeObjectForKey:msgModel.message.messageId];
        [dels addObject:@(delMsgIndex)];
    }
    return dels;
}

- (NSMutableArray*)queryAllImageMessages
{
    NSMutableArray *allImageMessage = [NSMutableArray array];
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageModel* messageModel = obj;
            BOOL isImage = NO;
            if ([messageModel.message.messageObject isKindOfClass:[YSF_NIMImageObject class]]) {
                isImage = YES;
            }
            else if ([messageModel.message.messageObject isKindOfClass:[YSF_NIMCustomObject class]])
            {
                YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)messageModel.message.messageObject;
                if ([customObject.attachment isKindOfClass:[YSFRichText class]] ) {
                    isImage = YES;
                }
                else if ([customObject.attachment isKindOfClass:[YSFMachineResponse class]] ) {
                    isImage = YES;
                }
                else if ([customObject.attachment isKindOfClass:[YSFStaticUnion class]] ) {
                    isImage = YES;
                }
                else if ([customObject.attachment isKindOfClass:[YSFSubmittedBotForm class]] ) {
                    isImage = YES;
                }
            }
            if (isImage) {
                [allImageMessage addObject:messageModel.message];
            }
        }
    }];
    
    return allImageMessage;
}

- (void)cleanCache
{
    for (id item in _modelArray)
    {
        if ([item isKindOfClass:[YSFMessageModel class]])
        {
            YSFMessageModel *model = (YSFMessageModel *)item;
            [model cleanCache];
        }
    }
}

#pragma mark - private methods
- (void)insertMessage:(YSF_NIMMessage *)message{
    YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
    if ([self modelIsExist:model]) {
        return;
    }
    if (self.firstTimeInterval && self.firstTimeInterval - model.message.timestamp < self.showTimeInterval) {
        //此时至少有一条时间戳和一条消息
        //干掉时间戳
        [self.modelArray removeObjectAtIndex:0];
    }
    [self.modelArray insertObject:model atIndex:0];
    YSFTimestampModel *timeModel = [[YSFTimestampModel alloc] init];
    timeModel.messageTime = model.message.timestamp;
    [self.modelArray insertObject:timeModel atIndex:0];
    self.firstTimeInterval = model.message.timestamp;
    [self.msgIdDict setObject:model forKey:model.message.messageId];
}

- (void)insertMessageAt:(NSInteger)postion message:(YSF_NIMMessage *)message{
    YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
    if ([self modelIsExist:model]) {
        return;
    }
    [self.modelArray insertObject:model atIndex:postion];
    [self.msgIdDict setObject:model forKey:model.message.messageId];
}

- (void)appendMessage:(YSF_NIMMessage *)message{
    YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
    if ([self modelIsExist:model]) {
        return;
    }
    if (model.message.timestamp - self.lastTimeInterval > self.showTimeInterval) {
        YSFTimestampModel *timeModel = [[YSFTimestampModel alloc] init];
        timeModel.messageTime = model.message.timestamp;
        [self.modelArray addObject:timeModel];
    }
    [self.modelArray addObject:model];
    self.lastTimeInterval = model.message.timestamp;
    [self.msgIdDict setObject:model forKey:model.message.messageId];
}




@end

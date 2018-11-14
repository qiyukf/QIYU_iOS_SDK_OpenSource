//
//  NIMSessionMsgDatasource.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFSessionMsgDataSource.h"
#import "UIScrollView+YSFKit.h"
#import "YSFMessageModel.h"
#import "YSFTimestampModel.h"
#import "YSFRichText.h"
#import "YSFMachineResponse.h"
#import "YSFStaticUnion.h"
#import "YSFSubmittedBotForm.h"


@implementation YSFSessionMsgDataSource
- (instancetype)initWithSession:(YSF_NIMSession *)session
               showTimeInterval:(NSTimeInterval)timeInterval {
    self = [super init];
    if (self) {
        _currentSession = session;
        _showTimeInterval = timeInterval;
        _firstTimeInterval = 0;
        _lastTimeInterval = 0;
    }
    return self;
}

- (NSInteger)msgCount {
    return [_modelArray count];
}

- (NSInteger)indexAtModelArray:(YSFMessageModel *)model {
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

- (void)resetMessagesWithLimit:(NSInteger)limit {
    self.modelArray = [NSMutableArray array];
    self.msgIdDict = [NSMutableDictionary dictionary];
    self.firstTimeInterval = 0;
    self.lastTimeInterval  = 0;
    
    if (limit > 0) {
        NSArray *messages = [[[YSF_NIMSDK sharedSDK] conversationManager] messagesInSession:_currentSession
                                                                                    message:nil
                                                                                      limit:limit];
        [self appendMessages:messages];
        self.firstTimeInterval = [messages.firstObject timestamp];
        self.lastTimeInterval  = [messages.lastObject timestamp];
        if ([self.delegate respondsToSelector:@selector(messageDataIsReady)]) {
            [self.delegate messageDataIsReady];
        }
    }
}

#pragma mark - 消息插入
- (NSArray *)appendMessages:(NSArray *)messages {
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

- (NSInteger)insertMessages:(NSArray *)messages {
    NSInteger count = self.modelArray.count;
    for (YSF_NIMMessage *message in messages.reverseObjectEnumerator.allObjects) {
        [self insertMessage:message];
    }
    return (self.modelArray.count - count);
}

- (NSInteger)insertMessagesAt:(NSInteger)postion messages:(NSArray *)messages {
    NSInteger count = self.modelArray.count;
    for (YSF_NIMMessage *message in messages.reverseObjectEnumerator.allObjects) {
        [self insertMessageAt:postion message:message];
    }
    return (self.modelArray.count - count);
}

#pragma mark - 消息追加
- (NSArray*)addMessages:(NSArray*)messages {
    return [self appendMessages:messages];
}

#pragma mark - 消息删除
- (NSArray*)deleteMessageModel:(YSFMessageModel *)msgModel {
    NSMutableArray *dels = [NSMutableArray array];
    NSInteger delTimeIndex = -1;
    NSInteger delMsgIndex = [_modelArray indexOfObject:msgModel];
    if (delMsgIndex > 0) {
        BOOL delMsgIsSingle = (delMsgIndex == (_modelArray.count - 1) || [_modelArray[delMsgIndex + 1] isKindOfClass:[YSFTimestampModel class]]);
        if ([_modelArray[delMsgIndex - 1] isKindOfClass:[YSFTimestampModel class]] && delMsgIsSingle) {
            delTimeIndex = delMsgIndex - 1;
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

#pragma mark - 历史消息加载
- (void)loadHistoryMessagesWithLimit:(NSInteger)limit
                   historyTipMessage:(YSF_NIMMessage *)tipMsg
                          completion:(void(^)(NSInteger index, NSError *error))completion {
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
                                                                                      limit:limit];
        NSMutableArray *mutableMsgs = [NSMutableArray arrayWithArray:messages];
        if (tipMsg) {
            [mutableMsgs addObject:tipMsg];
        }
        index = [self insertMessages:mutableMsgs];
    }
    if (completion) {
        ysf_dispatch_async_main(^{
            completion(index, nil);
        });
    }
}

#pragma mark - 查询消息
- (YSF_NIMMessage *)getLastMessageFromDB {
    NSArray *messages = [[[YSF_NIMSDK sharedSDK] conversationManager] messagesInSession:_currentSession
                                                                                message:nil
                                                                                  limit:1];
    if (messages && messages.count) {
        return [messages lastObject];
    }
    return nil;
}

- (NSMutableArray *)queryAllImageMessages {
    NSMutableArray *allImageMessage = [NSMutableArray array];
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageModel* messageModel = obj;
            BOOL isImage = NO;
            if ([messageModel.message.messageObject isKindOfClass:[YSF_NIMImageObject class]]) {
                isImage = YES;
            } else if ([messageModel.message.messageObject isKindOfClass:[YSF_NIMCustomObject class]]) {
                YSF_NIMCustomObject *customObject = (YSF_NIMCustomObject *)messageModel.message.messageObject;
                if ([customObject.attachment isKindOfClass:[YSFRichText class]] ) {
                    isImage = YES;
                } else if ([customObject.attachment isKindOfClass:[YSFMachineResponse class]] ) {
                    isImage = YES;
                } else if ([customObject.attachment isKindOfClass:[YSFStaticUnion class]] ) {
                    isImage = YES;
                } else if ([customObject.attachment isKindOfClass:[YSFSubmittedBotForm class]] ) {
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

#pragma mark - 清除缓存
- (void)cleanCache {
    for (id item in _modelArray) {
        if ([item isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageModel *model = (YSFMessageModel *)item;
            [model cleanCache];
        }
    }
}

#pragma mark - private methods
- (void)appendMessage:(YSF_NIMMessage *)message {
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

- (void)insertMessage:(YSF_NIMMessage *)message {
    YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
    if ([self modelIsExist:model]) {
        return;
    }
    if (self.firstTimeInterval && (self.firstTimeInterval - model.message.timestamp < self.showTimeInterval)) {
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

- (void)insertMessageAt:(NSInteger)postion message:(YSF_NIMMessage *)message {
    YSFMessageModel *model = [[YSFMessageModel alloc] initWithMessage:message];
    if ([self modelIsExist:model]) {
        return;
    }
    [self.modelArray insertObject:model atIndex:postion];
    [self.msgIdDict setObject:model forKey:model.message.messageId];
}

- (BOOL)modelIsExist:(YSFMessageModel *)model {
    return ([_msgIdDict objectForKey:model.message.messageId] != nil);
}

@end

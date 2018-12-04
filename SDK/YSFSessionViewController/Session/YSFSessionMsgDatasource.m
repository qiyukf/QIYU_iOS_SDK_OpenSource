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
#import "YSFNotification.h"

#import "QYCustomMessage.h"
#import "QYCustomModel.h"
#import "QYCustomModel_Private.h"
#import "YSFCustomMessageManager.h"


@implementation YSFSessionMsgDataSource
- (instancetype)initWithSession:(YSF_NIMSession *)session showTimeInterval:(NSTimeInterval)timeInterval {
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

- (NSInteger)indexAtModelArray:(id)model {
    __block NSInteger index = -1;
    if (![_msgIdDict objectForKey:[self messageIdForModel:model]]) {
        return index;
    }
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]] || [obj isKindOfClass:[QYCustomModel class]]) {
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
- (NSArray*)deleteMessageModel:(id)msgModel {
    NSMutableArray *dels = [NSMutableArray array];
    NSInteger count = _modelArray.count;
    NSInteger delTimeIndex = -1;
    NSInteger delMsgIndex = [_modelArray indexOfObject:msgModel];
    if (delMsgIndex > 0 && delMsgIndex < count) {
        BOOL delMsgIsSingle = (delMsgIndex == (count - 1)
                               || ((delMsgIndex < (count - 1)) && [_modelArray[delMsgIndex + 1] isKindOfClass:[YSFTimestampModel class]]));
        if ([_modelArray[delMsgIndex - 1] isKindOfClass:[YSFTimestampModel class]] && delMsgIsSingle) {
            delTimeIndex = delMsgIndex - 1;
            [_modelArray removeObjectAtIndex:delTimeIndex];
            [dels addObject:@(delTimeIndex)];
        }
    }
    if (delMsgIndex >= 0 && delMsgIndex < count) {
        [_modelArray removeObject:msgModel];
        NSString *msgId = [self messageIdForModel:msgModel];
        if (msgId.length) {
            [_msgIdDict removeObjectForKey:msgId];
        }
        [dels addObject:@(delMsgIndex)];
    }
    return dels;
}

#pragma mark - 历史消息加载
- (void)loadHistoryMessagesWithLimit:(NSInteger)limit
                   historyTipMessage:(YSF_NIMMessage *)tipMsg
                          completion:(void(^)(NSInteger index, NSError *error))completion {
    __block YSF_NIMMessage *curOldestMsg = nil;
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageModel *msgModel = (YSFMessageModel *)obj;
            curOldestMsg = msgModel.message;
            *stop = YES;
        } else if ([obj isKindOfClass:[QYCustomModel class]]) {
            QYCustomModel *msgModel = (QYCustomModel *)obj;
            curOldestMsg = msgModel.ysfMessage;
            *stop = YES;
        }
    }];
    NSInteger index = 0;
    if (curOldestMsg) {
        NSArray *messages = [[[YSF_NIMSDK sharedSDK] conversationManager] messagesInSession:_currentSession
                                                                                    message:curOldestMsg
                                                                                      limit:limit];
        if (messages) {
            if ([messages count] && tipMsg) {
                NSMutableArray *mutableMsgs = [NSMutableArray arrayWithArray:messages];
                [mutableMsgs addObject:tipMsg];
                index = [self insertMessages:mutableMsgs];
            } else {
                index = [self insertMessages:messages];
            }
        }
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

- (YSF_NIMMessage *)fetchCustomMessageForMessageId:(NSString *)messageId {
    __block YSF_NIMMessage *message = nil;
    [_modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YSF_NIMMessage *objMsg = [self messageForModel:obj];
        if (objMsg && [objMsg.messageId isEqualToString:messageId]) {
            message = objMsg;
            *stop = YES;
        }
    }];
    return message;
}

#pragma mark - 清除缓存
- (void)cleanCache {
    for (id item in _modelArray) {
        if ([item isKindOfClass:[YSFMessageModel class]]) {
            YSFMessageModel *model = (YSFMessageModel *)item;
            [model cleanCache];
        } else if ([item isKindOfClass:[QYCustomModel class]]) {
            QYCustomModel *model = (QYCustomModel *)item;
            [model cleanCache];
        }
    }
}

#pragma mark - private methods
- (void)appendMessage:(YSF_NIMMessage *)message {
    id model = nil;
    if ([[YSFCustomMessageManager sharedManager] isCustomMessage:message]) {
        model = [[YSFCustomMessageManager sharedManager] makeModelForYSFMessage:message];
    } else {
        model = [[YSFMessageModel alloc] initWithMessage:message];
    }
    if (!model || [self modelIsExist:model]) {
        return;
    }
    YSF_NIMMessage *modelMsg = [self messageForModel:model];
    if (modelMsg.timestamp - self.lastTimeInterval > self.showTimeInterval) {
        YSFTimestampModel *timeModel = [[YSFTimestampModel alloc] init];
        timeModel.messageTime = modelMsg.timestamp;
        [self.modelArray addObject:timeModel];
    }
    [self.modelArray addObject:model];
    self.lastTimeInterval = modelMsg.timestamp;
    if (modelMsg.messageId.length) {
        [self.msgIdDict setObject:model forKey:modelMsg.messageId];
    }
}

- (void)insertMessage:(YSF_NIMMessage *)message {
    id model = nil;
    if ([[YSFCustomMessageManager sharedManager] isCustomMessage:message]) {
        model = [[YSFCustomMessageManager sharedManager] makeModelForYSFMessage:message];
    } else {
        model = (YSFMessageModel *)[[YSFMessageModel alloc] initWithMessage:message];
    }
    if (!model || [self modelIsExist:model]) {
        return;
    }
    YSF_NIMMessage *modelMsg = [self messageForModel:model];
    if (self.firstTimeInterval && (self.firstTimeInterval - modelMsg.timestamp < self.showTimeInterval)) {
        //此时至少有一条时间戳和一条消息，移除掉时间戳
        if ([self.modelArray count] > 0) {
            id obj = [self.modelArray objectAtIndex:0];
            if (obj && [obj isKindOfClass:[YSFTimestampModel class]]) {
                [self.modelArray removeObjectAtIndex:0];
            }
        }
    }
    [self.modelArray insertObject:model atIndex:0];
    
    if (![self isHistoryTipMessage:message]) {
        YSFTimestampModel *timeModel = [[YSFTimestampModel alloc] init];
        timeModel.messageTime = modelMsg.timestamp;
        [self.modelArray insertObject:timeModel atIndex:0];
    }
    
    self.firstTimeInterval = modelMsg.timestamp;
    if (modelMsg.messageId.length) {
        [self.msgIdDict setObject:model forKey:modelMsg.messageId];
    }
}

- (void)insertMessageAt:(NSInteger)postion message:(YSF_NIMMessage *)message {
    if (postion >= 0 && postion <= self.modelArray.count) {
        id model = nil;
        if ([[YSFCustomMessageManager sharedManager] isCustomMessage:message]) {
            model = [[YSFCustomMessageManager sharedManager] makeModelForYSFMessage:message];
        } else {
            model = [[YSFMessageModel alloc] initWithMessage:message];
        }
        if (!model || [self modelIsExist:model]) {
            return;
        }
        [self.modelArray insertObject:model atIndex:postion];
        
        NSString *msgId = [self messageIdForModel:model];
        if (msgId.length) {
            [self.msgIdDict setObject:model forKey:msgId];
        }
    }
}

- (BOOL)modelIsExist:(id)model {
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        YSFMessageModel *msgModel = (YSFMessageModel *)model;
        return ([_msgIdDict objectForKey:msgModel.message.messageId] != nil);
    } else if ([model isKindOfClass:[QYCustomModel class]]) {
        QYCustomModel *msgModel = (QYCustomModel *)model;
        return ([_msgIdDict objectForKey:msgModel.message.messageId] != nil);
    }
    return NO;
}

- (BOOL)isHistoryTipMessage:(YSF_NIMMessage *)message {
    if (message.messageType == YSF_NIMMessageTypeCustom
        && [message.messageObject isKindOfClass:[YSF_NIMCustomObject class]]) {
        YSF_NIMCustomObject *customObj = (YSF_NIMCustomObject *)message.messageObject;
        if ([customObj.attachment isKindOfClass:[YSFNotification class]]) {
            YSFNotification *notification = (YSFNotification *)customObj.attachment;
            if (notification.localCommand == YSFCommandHistoryNotification) {
                return YES;
            }
        }
    }
    return NO;
}

- (YSF_NIMMessage *)messageForModel:(id)model {
    YSF_NIMMessage *message = nil;
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        YSFMessageModel *msgModel = (YSFMessageModel *)model;
        message = msgModel.message;
    } else if ([model isKindOfClass:[QYCustomModel class]]) {
        QYCustomModel *msgModel = (QYCustomModel *)model;
        message = msgModel.ysfMessage;
    }
    return message;
}

- (NSString *)messageIdForModel:(id)model {
    NSString *msgId = @"";
    if ([model isKindOfClass:[YSFMessageModel class]]) {
        YSFMessageModel *msgModel = (YSFMessageModel *)model;
        msgId = msgModel.message.messageId;
    } else if ([model isKindOfClass:[QYCustomModel class]]) {
        QYCustomModel *msgModel = (QYCustomModel *)model;
        msgId = msgModel.ysfMessage.messageId;
    }
    return msgId;
}

@end

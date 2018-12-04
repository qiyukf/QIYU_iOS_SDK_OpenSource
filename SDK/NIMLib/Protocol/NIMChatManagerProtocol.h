//
//  NIMChatManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessage.h"

/**
 *  聊天委托
 */
@protocol YSF_NIMChatManagerDelegate <NSObject>

@optional
/**
 *  即将发送消息回调
 *  @discussion 因为发消息之前可能会有个异步的准备过程,所以需要在收到这个回调时才将消息加入到datasource中
 *  @param message 当前发送的消息
 */
- (void)willSendMessage:(YSF_NIMMessage *)message;

/**
 *  发送消息进度回调
 *
 *  @param message  当前发送的消息
 *  @param progress 进度
 */
- (void)sendMessage:(YSF_NIMMessage *)message
           progress:(CGFloat)progress;

/**
 *  发送消息完成回调
 *
 *  @param message 当前发送的消息
 *  @param error   失败原因,如果发送成功则error为nil
 */
- (void)sendMessage:(YSF_NIMMessage *)message
    didCompleteWithError:(NSError *)error;


/**
 *  收到消息回调
 *
 *  @param messages 消息列表,内部为YSF_NIMMessage
 */
- (void)onRecvMessages:(NSArray *)messages;

- (void)onAddMessage:(YSF_NIMMessage *)message;

- (void)onUpdateMessage:(YSF_NIMMessage *)message;

/**
 *  收取消息附件回调
 *  @discussion 附件包括:图片,视频的缩略图,语音文件
 *  @param message  当前收取的消息
 *  @param progress 进度
 */
- (void)fetchMessageAttachment:(YSF_NIMMessage *)message
                      progress:(CGFloat)progress;


/**
 *  收取消息附件完成回调
 *
 *  @param message 当前收取的消息
 *  @param error   错误返回,如果收取成功,error为nil
 */
- (void)fetchMessageAttachment:(YSF_NIMMessage *)message
          didCompleteWithError:(NSError *)error;

@end


/**
 *  聊天协议
 */
@protocol YSF_NIMChatManager <NSObject>

/**
 *  发送消息
 *
 *  @param message 消息
 *  @param session 接受方
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的result只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)sendMessage:(YSF_NIMMessage *)message
          toSession:(YSF_NIMSession *)session
              error:(NSError **)error;

/**
 *  发送消息（隐式）
 *
 *  @param message 消息
 *  @param session 接受方
 *  @param visible 消息是否可见
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的result只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)sendMessage:(YSF_NIMMessage *)message
          toSession:(YSF_NIMSession *)session
            visible:(BOOL)visible
              error:(NSError **)error;

/**
 *  重发消息
 *
 *  @param message 重发消息
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的result只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)resendMessage:(YSF_NIMMessage *)message
                error:(NSError **)error;



/**
 *  收取消息附件
 *
 *  @param message 需要收取附件的消息
 *  @param error   错误
 *
 *  @return 是否调用成功
 */
- (BOOL)fetchMessageAttachment:(YSF_NIMMessage *)message
                         error:(NSError **)error;

/**
 *  消息是否正在传输 (发送/接受附件)
 *
 *  @param message 消息
 *
 *  @return 是否正在传输
 */
- (BOOL)messageInTransport:(YSF_NIMMessage *)message;

/**	
 *  传输消息的进度 (发送/接受附件)
 *
 *  @param message 消息
 *
 *  @return 正在传输的消息进度,如果消息不在传输,则返回0
 */
- (CGFloat)messageTransportProgress:(YSF_NIMMessage *)message;

/**
 *  添加聊天委托
 *
 *  @param delegate 聊天委托
 */
- (void)addDelegate:(id<YSF_NIMChatManagerDelegate>)delegate;

/**
 *  移除聊天委托
 *
 *  @param delegate 聊天委托
 */
- (void)removeDelegate:(id<YSF_NIMChatManagerDelegate>)delegate;

//七鱼新增接口
- (void)setReceiveMessageFrom:(NSString *)shopID receiveMessageFrom:(NSString *)receiveMessageFrom;
- (NSString *)getReceiveMessageFrom:(NSString *)shopID;
- (void)setUniqueMessageFrom:(NSString *)uniqueFrom;
- (NSString *)getUniqueMessageFrom;

@end

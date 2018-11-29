//
//  NIMSessionMsgDatasource.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@protocol NIMSessionMsgDatasourceDelegate <NSObject>

- (void)messageDataIsReady;

@end


@interface YSFSessionMsgDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSMutableDictionary *msgIdDict;
@property (nonatomic, strong) YSF_NIMSession *currentSession;
@property (nonatomic, readonly) NSInteger showTimeInterval; //两条消息相隔多久显示一条时间戳
@property (nonatomic, weak) id<NIMSessionMsgDatasourceDelegate> delegate;
//因插入的消息发送完毕后会改为服务器时间，所以不能简单和前一条消息对比时间戳去插时间；这里记下插入时的本地时间做对比
@property (nonatomic, assign) NSTimeInterval firstTimeInterval;
@property (nonatomic, assign) NSTimeInterval lastTimeInterval;

- (instancetype)initWithSession:(YSF_NIMSession *)session
               showTimeInterval:(NSTimeInterval)timeInterval;

- (NSInteger)msgCount;
- (NSInteger)indexAtModelArray:(id)model;

/**
 *  复位消息
 *  @param limit 加载消息数量
 */
- (void)resetMessagesWithLimit:(NSInteger)limit;

/**
 *  从后插入消息
 *  @param messages 消息集合
 *  @return 插入消息的index集合
 */
- (NSArray *)appendMessages:(NSArray *)messages;

/**
 *  从头插入消息
 *  @param messages 消息集合
 *  @return 插入后table要滑动到的位置
 */
- (NSInteger)insertMessages:(NSArray *)messages;
- (NSInteger)insertMessagesAt:(NSInteger)postion messages:(NSArray *)messages;

/**
 *  追加消息
 *  @param messages 消息集合
 *  @return 插入消息的index集合
 */
- (NSArray *)addMessages:(NSArray *)messages;

/**
 *  删除消息
 *  @param model 需删除的消息
 *  @return 删除消息的index集合（可能包含时间消息）
 */
- (NSArray *)deleteMessageModel:(id)model;

/**
 *  加载历史消息
 *  @param limit 加载消息数量
 *  @param tipMsg 历史消息提示
 *  @return 加载后table要滑动到的位置
 */
- (void)loadHistoryMessagesWithLimit:(NSInteger)limit
                   historyTipMessage:(YSF_NIMMessage *)tipMsg
                          completion:(void(^)(NSInteger index, NSError *error))completion;

/**
 *  查询最后一条消息
 */
- (YSF_NIMMessage *)getLastMessageFromDB;

/**
 *  查询所有图片相关消息
 */
- (NSMutableArray *)queryAllImageMessages;

/**
 *  查询消息
 */
- (YSF_NIMMessage *)fetchCustomMessageForMessageId:(NSString *)messageId;

/**
 *  清除model缓存布局数据
 */
- (void)cleanCache;

@end

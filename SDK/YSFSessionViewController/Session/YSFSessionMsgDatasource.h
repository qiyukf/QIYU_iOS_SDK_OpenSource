//
//  NIMSessionMsgDatasource.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFMessageModel;

@protocol NIMSessionMsgDatasourceDelegate <NSObject>

- (void)messageDataIsReady;

@end

@interface YSFSessionMsgDatasource : NSObject

- (instancetype)initWithSession:(YSF_NIMSession*)session
               showTimeInterval:(NSTimeInterval)timeInterval
                          limit:(NSInteger)limit;


@property (nonatomic,strong) NSMutableDictionary *msgIdDict;

//因为插入消息之后，消息到发送完毕后会改成服务器时间，所以不能简单和前一条消息对比时间戳去插时间
//这里记下来插消息时的本地时间，按这个去比
@property (nonatomic,assign) NSTimeInterval firstTimeInterval;

@property (nonatomic,assign) NSTimeInterval lastTimeInterval;

@property (nonatomic,strong) YSF_NIMSession *currentSession;

@property (nonatomic, strong) NSMutableArray      *modelArray;
@property (nonatomic, readonly) NSInteger         messageLimit;                //每页消息显示条数
@property (nonatomic, readonly) NSInteger         showTimeInterval;            //两条消息相隔多久显示一条时间戳
@property (nonatomic, weak) id<NIMSessionMsgDatasourceDelegate> delegate;

- (NSInteger)indexAtModelArray:(YSFMessageModel*)model;
- (NSInteger)msgCount;

//复位消息
- (void)resetMessages;

//数据对外接口
- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index , NSError *error))handler;

- (NSArray *)appendMessages:(NSArray *)messages;
- (NSInteger)insertMessages:(NSArray *)messages;
- (NSInteger)insertMessagesAt:(NSInteger)postion messages:(NSArray *)messages;

- (NSArray*)addMessages:(NSArray*)messages;
- (NSArray*)deleteMessageModel:(YSFMessageModel*)model;

- (NSMutableArray*)queryAllImageMessages;

- (void)cleanCache;
@end

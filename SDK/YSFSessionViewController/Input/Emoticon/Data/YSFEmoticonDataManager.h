//
//  YSFEmoticonDataManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFEmoticonDefines.h"
#import "YSFEmoticonData.h"


typedef void (^YSFEmoticonCompletion)(NSError *error);


@interface YSFEmoticonDataManager : NSObject

@property (nonatomic, copy) NSString *emoticonRootPath;
@property (nonatomic, copy) NSString *emojiPath;
@property (nonatomic, assign) BOOL needRequest;
@property (nonatomic, strong) NSMutableArray <YSFEmoticonPackage *> *packageList;
@property (nonatomic, strong) NSMutableDictionary *emojiMap;    //映射关系：tag->YSFEmoticonItem

+ (instancetype)sharedManager;

/**
 * 仅加载本地默认emoji表情数据
 */
- (void)onlyloadDefaultEmojiData;

/**
 * 数据持久化
 */
- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key;
- (void)saveArray:(NSArray *)array forKey:(NSString *)key;
- (NSDictionary *)dictByKey:(NSString *)key;
- (NSArray *)arrayByKey:(NSString *)key;

/**
 * 请求表情列表数据，请求时机：点击表情按钮时，且一通人工会话仅请求一次
 * 首次请求，展示loading动画；再次请求，先直接展示旧数据，等待请求完成后刷新界面
 */
- (void)requestEmoticonListTimeoutInterval:(NSTimeInterval)timeoutInterval
                                completion:(YSFEmoticonCompletion)completion;

/**
 * 请求表情map数据，请求时机：1、进入聊天界面时；2、点击表情按钮时，跟随列表数据一起
 */
- (void)requestEmoticonMapTimeoutInterval:(NSTimeInterval)timeoutInterval
                               completion:(YSFEmoticonCompletion)completion;

/**
 * 先请求map数据，完成后请求list数据，并将map数据填充至list中；点击表情按钮时直接使用此接口
 * 加载失败以list数据为准，map加载失败不提示
 */
- (void)requestEmoticonDataCompletion:(YSFEmoticonCompletion)completion;

/**
 * 以tag为Key获取emoji表情数据
 */
- (YSFEmoticonItem *)emoticonItemForTag:(NSString *)tag;

/**
 * 以id为Key获取自定义emoji表情tag
 */
- (NSString *)emoticonTagForID:(NSString *)emoticonID;



@end


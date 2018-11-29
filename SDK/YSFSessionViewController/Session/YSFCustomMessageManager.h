//
//  YSFCustomMessageManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QYCustomModel;

@interface YSFCustomMessageManager : NSObject

+ (instancetype)sharedManager;

/**
 *  清除所有映射关系
 */
- (void)cleanCache;

/**
 *  注册message-model-contentView的映射关系
 *  @param messageClass     消息类
 *  @param modelClass       消息对应的数据模型类
 *  @param contentViewClass 消息对应的视图
 */
- (void)registerCustomMessageClass:(Class)messageClass
                        modelClass:(Class)modelClass
                  contentViewClass:(Class)contentViewClass;

/**
 *  取出某自定义消息对应的数据模型类名
 *  @param messageClass     消息类
 *  @return 消息对应的数据模型类
 */
- (NSString *)modelClassNameForMessageClass:(Class)messageClass;

/**
 *  取出某自定义消息对应的视图类名
 *  @param messageClass     消息类
 *  @return 消息对应的视图
 */
- (NSString *)contentClassNameForMessageClass:(Class)messageClass;

/**
 *  判断某条消息是否是自定义
 *  @param message     消息体
 *  @return 是否是自定义消息
 */
- (BOOL)isCustomMessage:(YSF_NIMMessage *)message;

/**
 *  取出底层消息对应的数据模型类名
 *  @param message     消息体
 *  @return 数据模型类名
 */
- (NSString *)modelClassNameForYSFMessage:(YSF_NIMMessage *)message;

/**
 *  取出底层消息对应的数据模型类
 *  @param message     消息体
 *  @return 数据模型类
 */
- (QYCustomModel *)makeModelForYSFMessage:(YSF_NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END

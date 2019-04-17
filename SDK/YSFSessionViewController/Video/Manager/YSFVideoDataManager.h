//
//  YSFVideoDataManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AssetsLibrary;
@import Photos;


typedef void(^YSFVideoDataCompletion)(BOOL success);
typedef void(^YSFVideoDataProgressBlock)(CGFloat progress);


@interface YSFVideoDataManager : NSObject

/**
 * 单例初始化
 */
+ (instancetype)sharedManager;

/**
 * 保存至相册
 */
- (void)saveVideoToSystemLibrary:(NSString *)path completion:(YSFVideoDataCompletion)completion;

/**
 * 删除七鱼侧本地视频文件
 */
- (void)deleteVideoDataPath:(NSString *)path completion:(YSFVideoDataCompletion)completion;

/**
 * 删除云信侧本地视频文件
 */
- (void)deleteNIMVideoDataPath:(NSString *)path completion:(YSFVideoDataCompletion)completion;

/**
 * 下载视频，先判断本地是否存在视频文件，若不存在则网络下载，下载文件存储至本地路径localPath
 */
- (void)downloadVideoDataWithLocalPath:(NSString *)localPath
                            remotePath:(NSString *)remotePath
                              progress:(YSFVideoDataProgressBlock)progressBlock
                            completion:(YSFVideoDataCompletion)completionBlock;

/**
 * 取消上传视频任务
 */
- (void)cancelUploadVideoDataWithPath:(NSString *)path;

@end



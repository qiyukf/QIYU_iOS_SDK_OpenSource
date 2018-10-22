//
//  YSFVideoDataManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@import AssetsLibrary;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSFVideoDataStartWriteHandler)(NSError *error);
typedef void(^YSFVideoDataStopWriteHandler)(NSURL * _Nullable url, NSError * _Nullable error);
typedef void(^YSFVideoDataCompletion)(BOOL success);
typedef void(^YSFVideoDataProgressBlock)(CGFloat progress);

@interface YSFVideoDataManager : NSObject

/**
 * 视频数据存放地址（七鱼侧）
 */
@property (nonatomic, copy) NSString *dataPath;

/**
 * 视频参考方向
 */
@property (nonatomic, assign) AVCaptureVideoOrientation referenceOrientation;

/**
 * 视频播放方向
 */
@property (nonatomic, assign) AVCaptureVideoOrientation currentOrientation;

/**
 * 当前设备
 */
@property (nonatomic, strong) AVCaptureDevice *currentDevice;

/**
 * 单例初始化/销毁
 */
+ (instancetype)sharedManager;
+ (void)destroyManager;

/**
 * 视频流数据写入
 */
- (void)startWriteDataHandler:(YSFVideoDataStartWriteHandler)handler;
- (void)stopWriteDataHandler:(YSFVideoDataStopWriteHandler)handler;
- (void)writeData:(AVCaptureConnection *)connection
  videoConnection:(AVCaptureConnection *)videoConnection
  audioConnection:(AVCaptureConnection *)audioConnection
           buffer:(CMSampleBufferRef)buffer;

/**
 * 保存至相册
 */
- (void)saveVideoToSystemLibrary:(NSString *)path completion:(_Nullable YSFVideoDataCompletion)completion;

/**
 * 删除七鱼侧本地视频文件
 */
- (void)deleteVideoDataCompletion:(_Nullable YSFVideoDataCompletion)completion;

/**
 * 删除云信侧本地视频文件
 */
- (void)deleteNIMVideoDataPath:(NSString *)path completion:(_Nullable YSFVideoDataCompletion)completion;

/**
 * 下载视频，先判断本地是否存在视频文件，若不存在则网络下载，下载文件存储至本地路径localPath
 */
- (void)downloadVideoDataWithLocalPath:(NSString *)localPath
                            remotePath:(NSString *)remotePath
                              progress:(_Nullable YSFVideoDataProgressBlock)progressBlock
                            completion:(_Nullable YSFVideoDataCompletion)completionBlock;

/**
 * 取消上传视频任务
 */
- (void)cancelUploadVideoDataWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END

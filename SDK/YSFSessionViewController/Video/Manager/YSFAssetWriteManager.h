//
//  YSFAssetWriteManager.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/4/12.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;


typedef void(^YSFVideoDataStartWriteHandler)(BOOL success, NSError *error);
typedef void(^YSFVideoDataStopWriteHandler)(NSURL *url, NSError *error);


@interface YSFAssetWriteManager : NSObject

/**
 * 视频数据存放地址（七鱼侧）
 */
@property (nonatomic, copy) NSString *dataPath;

/**
 * 视频输出大小
 */
@property (nonatomic, assign) CGSize outputSize;

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
 * 视频流数据写入
 */
- (void)startWriteDataHandler:(YSFVideoDataStartWriteHandler)handler;
- (void)stopWriteDataHandler:(YSFVideoDataStopWriteHandler)handler;
- (void)writeData:(AVCaptureConnection *)connection
  videoConnection:(AVCaptureConnection *)videoConnection
  audioConnection:(AVCaptureConnection *)audioConnection
           buffer:(CMSampleBufferRef)buffer;


@end



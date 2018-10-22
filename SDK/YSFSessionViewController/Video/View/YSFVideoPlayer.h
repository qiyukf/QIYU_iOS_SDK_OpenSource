//
//  YSFVideoPlayer.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSFVideoPlayerStatusBlock)(NSTimeInterval curTime, NSTimeInterval totalTime);

@class YSF_NIMMessage;
@interface YSFVideoPlayer : UIView

/**
 * 一般在播放视频VC出现时调用，包含了视频文件下载，完成后自动调用play进行播放
 * @param message  视频消息
 * @param soundOff  是否静音
 * @param statusBlock  状态回调
 */
- (void)startWithMessage:(YSF_NIMMessage *)message
                soundOff:(BOOL)soundOff
             statusBlock:(YSFVideoPlayerStatusBlock)statusBlock;

/**
 * 播放视频
 * @param time  从某时刻播放
 */
- (void)playFromTime:(CMTime)time;

/**
 * 播放视频
 */
- (void)play;

/**
 * 暂停播放
 */
- (void)pause;

/**
 * 一般在播放视频VC退出时调用，会移除KVO，取消正在下载的视频
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END

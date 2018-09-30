//
//  YSFVideoDataManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoDataManager.h"
#import "NIMUtil.h"

@interface YSFVideoDataManager () {
    dispatch_queue_t _dataQueue;
    NSURL *_videoURL;
    AVAssetWriter *_dataWriter;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInput *_audioInput;
    
    BOOL _readyToRecordVideo;
    BOOL _readyToRecordAudio;
}

@end

@implementation YSFVideoDataManager

static YSFVideoDataManager *sharedManager = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[YSFVideoDataManager alloc] init];
    });
    return sharedManager;
}

+ (void)destroyManager {
    sharedManager = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataQueue = dispatch_queue_create("com.netease.videoDataWriteQueue", DISPATCH_QUEUE_SERIAL);
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
    }
    return self;
}

- (void)setDataPath:(NSString *)dataPath {
    _dataPath = dataPath;
    if (dataPath.length) {
        _videoURL = [NSURL fileURLWithPath:dataPath];
    }
}

#pragma mark - public interface
- (void)startWriteDataHandler:(YSFVideoDataStartWriteHandler)handler {
    dispatch_async(_dataQueue, ^{
        NSError *error = nil;
        if (!self->_dataWriter) {
            self->_dataWriter = [[AVAssetWriter alloc] initWithURL:self->_videoURL fileType:AVFileTypeMPEG4 error:&error];
        }
        if (handler) {
            handler(error);
        }
    });
}

- (void)stopWriteDataHandler:(YSFVideoDataStopWriteHandler)handler {
    _readyToRecordVideo = NO;
    _readyToRecordAudio = NO;
    dispatch_async(_dataQueue, ^{
        if (AVAssetWriterStatusWriting == self->_dataWriter.status) {
            [self->_dataWriter finishWritingWithCompletionHandler:^{
                if (AVAssetWriterStatusCompleted == self->_dataWriter.status) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler(self->_videoURL, nil);
                        }
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler(nil, self->_dataWriter.error);
                        }
                    });
                }
                self->_dataWriter = nil;
            }];
        }
    });
}

- (void)writeData:(AVCaptureConnection *)connection
  videoConnection:(AVCaptureConnection *)videoConnection
  audioConnection:(AVCaptureConnection *)audioConnection
           buffer:(CMSampleBufferRef)buffer {
    CFRetain(buffer);
    dispatch_async(_dataQueue, ^{
        if (connection == videoConnection) {
            if (!self->_readyToRecordVideo) {
                self->_readyToRecordVideo = ([self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(buffer)] == nil);
            }
            if (self->_readyToRecordVideo && self->_readyToRecordAudio) {
                [self writeSampleBuffer:buffer ofType:AVMediaTypeVideo];
            }
        } else if (connection == audioConnection) {
            if (!self->_readyToRecordAudio) {
                self->_readyToRecordAudio = ([self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(buffer)] == nil);
            }
            if (self->_readyToRecordVideo && self->_readyToRecordAudio) {
                [self writeSampleBuffer:buffer ofType:AVMediaTypeAudio];
            }
        }
        CFRelease(buffer);
    });
}

- (void)saveVideoToSystemLibrary:(NSString *)path completion:(YSFVideoDataCompletion)completion {
    if (!path.length) {
        return;
    }
    if (YSFIOS8) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (PHAuthorizationStatusAuthorized != status) {
                if (completion) {
                    completion(NO);
                }
            } else {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                    [request addResourceWithType:PHAssetResourceTypeVideo fileURL:[NSURL fileURLWithPath:path] options:nil];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(success);
                        }
                    });
                }];
            }
        }];
    } else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(!error);
                }
            });
        }];
    }
}

- (void)deleteVideoDataCompletion:(YSFVideoDataCompletion)completion {
    BOOL success = NO;
    if (_dataPath.length) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_dataPath]) {
            success = [fileManager removeItemAtPath:_dataPath error:nil];
        }
    }
    if (completion) {
        completion(success);
    }
}

- (void)deleteNIMVideoDataPath:(NSString *)path completion:(YSFVideoDataCompletion)completion {
    if (path.length) {
        [[YSF_NIMSDK sharedSDK].resourceManager deleteFileByPath:path
                                                 completionBlock:^(NSError *error) {
                                                     BOOL success = (!error);
                                                     if (completion) {
                                                         completion(success);
                                                     }
                                                 }];
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

- (void)downloadVideoDataWithLocalPath:(NSString *)localPath
                            remotePath:(NSString *)remotePath
                              progress:(_Nullable YSFVideoDataProgressBlock)progressBlock
                            completion:(_Nullable YSFVideoDataCompletion)completionBlock {
    BOOL success = NO;
    if (localPath.length) {
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:localPath]) {
            success = YES;
        } else {
            if (remotePath.length) {
                [[YSF_NIMSDK sharedSDK].resourceManager download:remotePath
                                                        filepath:localPath
                                                        progress:^(CGFloat progress) {
                                                            if (progressBlock) {
                                                                progressBlock(progress);
                                                            }
                                                        }
                                                      completion:^(NSError *error) {
                                                          if (completionBlock) {
                                                              completionBlock(!error);
                                                          }
                                                      }];
            }
        }
    }
    if (completionBlock) {
        completionBlock(success);
    }
}

- (void)cancelUploadVideoDataWithPath:(NSString *)path {
    if (path.length) {
        [[YSF_NIMSDK sharedSDK].resourceManager cancelTask:path];
    }
}

#pragma mark - private interface
- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType {
    if (AVAssetWriterStatusUnknown == _dataWriter.status) {
        if ([_dataWriter startWriting]) {
            [_dataWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
//            NSLog(@"%@", _dataWriter.error);
        }
    }
    if (AVAssetWriterStatusWriting == _dataWriter.status) {
        if (mediaType == AVMediaTypeVideo) {
            if (!_videoInput.readyForMoreMediaData) {
                return;
            }
            if (![_videoInput appendSampleBuffer:sampleBuffer]) {
//                NSLog(@"%@", _dataWriter.error);
            }
        } else if (mediaType == AVMediaTypeAudio) {
            if (!_audioInput.readyForMoreMediaData) {
                return;
            }
            if (![_audioInput appendSampleBuffer:sampleBuffer]) {
//                NSLog(@"%@", _dataWriter.error);
            }
        }
    }
}

- (NSError *)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640 * 480) ? 4.05 : 10.1;
    NSDictionary *compression = @{AVVideoAverageBitRateKey: [NSNumber numberWithInteger: numPixels * bitsPerPixel],
                                  AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInteger:30]};
    NSDictionary *settings = @{AVVideoCodecKey: AVVideoCodecH264,
                               AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                               AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
                               AVVideoCompressionPropertiesKey: compression};
    
    if ([_dataWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]) {
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        _videoInput.expectsMediaDataInRealTime = YES;
        _videoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_dataWriter canAddInput:_videoInput]){
            [_dataWriter addInput:_videoInput];
        } else {
            return _dataWriter.error;
        }
    } else {
        return _dataWriter.error;
    }
    return nil;
}

- (NSError *)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *channelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    NSData *dataLayout = aclSize > 0 ? [NSData dataWithBytes:channelLayout length:aclSize] : [NSData data];
    NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                               AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                               AVChannelLayoutKey: dataLayout,
                               AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame],
                               AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000]};
    
    if ([_dataWriter canApplyOutputSettings:settings forMediaType: AVMediaTypeAudio]) {
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
        _audioInput.expectsMediaDataInRealTime = YES;
        if ([_dataWriter canAddInput:_audioInput]){
            [_dataWriter addInput:_audioInput];
        } else {
            return _dataWriter.error;
        }
    } else {
        return _dataWriter.error;
    }
    return nil;
}

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.currentOrientation];
    CGFloat angleOffset;
    if (self.currentDevice.position == AVCaptureDevicePositionBack) {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    } else {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    CGFloat angle = 0.0;
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
    }
    return angle;
}

@end

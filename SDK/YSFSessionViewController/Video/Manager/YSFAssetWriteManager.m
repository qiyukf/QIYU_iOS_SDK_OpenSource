//
//  YSFAssetWriteManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/4/12.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFAssetWriteManager.h"


@interface YSFAssetWriteManager () {
    NSURL *_videoURL;
    
    dispatch_queue_t _dataQueue;
    AVAssetWriter *_dataWriter;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInput *_audioInput;
    
    BOOL _readyToRecordVideo;
    BOOL _readyToRecordAudio;
}

@end


@implementation YSFAssetWriteManager
- (void)dealloc {
    YSFLogApp(@"");
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

- (void)startWriteDataHandler:(YSFVideoDataStartWriteHandler)handler {
    dispatch_async(_dataQueue, ^{
        NSError *error = nil;
        if (!self->_dataWriter) {
            self->_dataWriter = [[AVAssetWriter alloc] initWithURL:self->_videoURL fileType:AVFileTypeMPEG4 error:&error];
        }
        if (!error) {
            if (handler) {
                handler(YES, nil);
            }
        } else {
            if (handler) {
                handler(NO, error);
            }
        }
    });
}

- (void)stopWriteDataHandler:(YSFVideoDataStopWriteHandler)handler {
    _readyToRecordVideo = NO;
    _readyToRecordAudio = NO;
    dispatch_async(_dataQueue, ^{
        [self->_dataWriter finishWritingWithCompletionHandler:^{
            if (AVAssetWriterStatusCompleted == self->_dataWriter.status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler(self->_videoURL, nil);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler(nil, self->_dataWriter.error);
                    }
                });
            }
            self->_dataWriter = nil;
        }];
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
                self->_readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(buffer)];
            }
            if (self->_readyToRecordVideo && self->_readyToRecordAudio) {
                [self writeSampleBuffer:buffer ofType:AVMediaTypeVideo];
            }
        } else if (connection == audioConnection) {
            if (!self->_readyToRecordAudio) {
                self->_readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(buffer)];
            }
            if (self->_readyToRecordVideo && self->_readyToRecordAudio) {
                [self writeSampleBuffer:buffer ofType:AVMediaTypeAudio];
            }
        }
        
        CFRelease(buffer);
    });
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType {
    if (sampleBuffer == NULL) {
        YSFLogApp(@"sampleBuffer ERROR: null");
        return;
    }
    if (AVAssetWriterStatusUnknown == _dataWriter.status) {
        if ([_dataWriter startWriting]) {
            [_dataWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            YSFLogApp(@"AVAssetWriter ERROR: start fail");
        }
    }
    if (AVAssetWriterStatusWriting == _dataWriter.status) {
        if (mediaType == AVMediaTypeVideo) {
            if (_videoInput.readyForMoreMediaData) {
                BOOL success = [_videoInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    YSFLogApp(@"AVAssetWriter ERROR: append video buffer fail");
                }
            }
        } else if (mediaType == AVMediaTypeAudio) {
            if (_audioInput.readyForMoreMediaData) {
                BOOL success = [_audioInput appendSampleBuffer:sampleBuffer];
                if (!success) {
                    YSFLogApp(@"AVAssetWriter ERROR: append audio buffer fail");
                }
            }
        }
    }
}

- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    NSUInteger numPixels = self.outputSize.width * self.outputSize.height;
    CGFloat bitsPerPixel = 6.0;
    NSDictionary *compression = @{ AVVideoAverageBitRateKey: @(numPixels * bitsPerPixel),
                                   AVVideoMaxKeyFrameIntervalKey: @(30) };
    NSDictionary *settings = @{ AVVideoCodecKey: AVVideoCodecH264,
                                AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                AVVideoWidthKey: @(self.outputSize.height * 2),
                                AVVideoHeightKey: @(self.outputSize.width * 2),
                                AVVideoCompressionPropertiesKey: compression };
    
    if ([_dataWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]) {
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        _videoInput.expectsMediaDataInRealTime = YES;
        _videoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_dataWriter canAddInput:_videoInput]){
            [_dataWriter addInput:_videoInput];
        } else {
            YSFLogApp(@"AVAssetWriter ERROR: can not add video input");
            return NO;
        }
    } else {
        YSFLogApp(@"AVAssetWriter ERROR: can not apply video settings");
        return NO;
    }
    return YES;
}

- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {    
    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                               AVSampleRateKey: @(22050),
                               AVNumberOfChannelsKey: @(1),
                               AVEncoderBitRatePerChannelKey: @(28000)};
    
    if ([_dataWriter canApplyOutputSettings:settings forMediaType: AVMediaTypeAudio]) {
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
        _audioInput.expectsMediaDataInRealTime = YES;
        if ([_dataWriter canAddInput:_audioInput]){
            [_dataWriter addInput:_audioInput];
        } else {
            YSFLogApp(@"AVAssetWriter ERROR: can not add audio input");
            return NO;
        }
    } else {
        YSFLogApp(@"AVAssetWriter ERROR: can not apply audio settings");
        return NO;
    }
    return YES;
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

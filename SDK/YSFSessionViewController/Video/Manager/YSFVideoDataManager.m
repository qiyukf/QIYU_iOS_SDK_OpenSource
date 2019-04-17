//
//  YSFVideoDataManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoDataManager.h"
#import "NIMUtil.h"


@implementation YSFVideoDataManager

static YSFVideoDataManager *sharedManager = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[YSFVideoDataManager alloc] init];
    });
    return sharedManager;
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

- (void)deleteVideoDataPath:(NSString *)path completion:(_Nullable YSFVideoDataCompletion)completion {
    BOOL success = NO;
    if (path.length) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            success = [fileManager removeItemAtPath:path error:nil];
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


@end

//
//  YSFPathManager.m
//  YSFSDK
//
//  Created by amao on 8/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFPathManager.h"
#import "QYSDK_Private.h"

@interface YSFPathManager ()

@property (nonatomic, copy) NSString *sdkRootPath;
@property (nonatomic, copy) NSString *globalPath;
@property (nonatomic, copy) NSString *videoPath;

@end

@implementation YSFPathManager
- (instancetype)init {
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _sdkRootPath = [[paths firstObject] stringByAppendingPathComponent:@"YSFSDK"];
        
        [self createDirIfNotExists:_sdkRootPath];
    }
    return self;
}

- (void)setup:(NSString *)appKey {
    NSString *appKeyMD5 = [appKey ysf_md5];
    NSString *appRootPath = [_sdkRootPath stringByAppendingPathComponent:appKeyMD5];
    _globalPath = [appRootPath stringByAppendingPathComponent:@"Global"];
    _videoPath = [_globalPath stringByAppendingString:@"/video"];
    
    [self createDirIfNotExists:_globalPath];
    [self createDirIfNotExists:_videoPath];
    [self addSkipBackup:_globalPath];
}


#pragma mark - Public API 
- (NSString *)sdkRootPath {
    return _sdkRootPath;
}

- (NSString *)sdkGlobalPath {
    return _globalPath;
}

- (NSString *)sdkVideoPath {
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:_videoPath isDirectory:&isDir];
    if (!existed) {
        [fileManager createDirectoryAtPath:_videoPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else if (!isDir) {
        [fileManager removeItemAtPath:_videoPath error:nil];
        [fileManager createDirectoryAtPath:_videoPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return _videoPath;
}

#pragma mark - misc
- (void)addSkipBackup:(NSString *)filepath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSURL *url = [NSURL fileURLWithPath:filepath];
        BOOL success = [url setResourceValue:@(YES)
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:nil];
        if (!success) {
            
        }
    }
}

- (void)createDirIfNotExists:(NSString *)dirPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

@end

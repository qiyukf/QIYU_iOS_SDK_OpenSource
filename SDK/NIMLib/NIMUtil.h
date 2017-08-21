//
//  YSF_NIMUtil.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSF_NIMUtil : NSObject

//返回UUID
+ (NSString *)uuid;

//生成文件名
+ (NSString *)genFilenameWithExt: (NSString *)ext;

@end

@interface YSF_NIMUtil(Media)

+ (BOOL)mediaLengthIsTooShort:(NSString *)filepath;

//获取media length,以毫秒为单位
+ (NSInteger)mediaLengthForFile:(NSString *)filepath;

//产生缩略图
+ (UIImage *)generateThumbForVideo:(NSString *)filepath;

//是否是有效的多媒体
+ (BOOL)isValidMedia:(NSString *)filepath;

+ (NSInteger)sampleRateForFile:(NSString *)filepath;


@end

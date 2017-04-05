//
//  YSF_NIMFileObject.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMessageObjectProtocol.h"
/**
 *  文件的实例对象
 */
@interface YSF_NIMFileObject : NSObject<YSF_NIMMessageObject>

/**
 *  文件对象初始化方法(根据文件路径)
 *
 *  @param sourcePath 文件路径
 *
 *  @return 文件实例对象
 */
- (instancetype)initWithSourcePath:(NSString *)sourcePath;


/**
 *  文件对象初始化方法(根据文件数据)
 *
 *  @param data 文件数据
 *  @param extension 文件拓展名
 *  @return 文件实例对象
 */

- (instancetype)initWithData:(NSData*)data extension:(NSString*)extension;


/**
 *  文件显示名
 */
@property (nonatomic, copy)  NSString *displayName;

/**
 *  文件的本地路径
 */
@property (nonatomic, copy, readonly) NSString *path;

/**
 *  文件的远程路径
 */
@property (nonatomic, copy, readonly) NSString *url;


/**
 *  文件MD5
 */
@property (nonatomic, copy, readonly) NSString * md5;

/**
 *  文件大小
 */
@property (nonatomic, assign, readonly) long long fileLength;

/**
 *  失效时间
 */
@property (nonatomic,assign, readonly) NSTimeInterval expire;


@end

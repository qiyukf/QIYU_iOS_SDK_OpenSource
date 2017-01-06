//
//  YSF_NIMServerSetting.h
//  NIMLib
//
//  Created by amao on 15/4/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSF_NIMServerSetting;


@interface YSF_NIMServerSetting : NSObject
@property (nonatomic,copy)      NSString    *lbsAddress;                //APP lbs地址
@property (nonatomic,copy)      NSString    *nosLbsAddress;             //NOS lbs地址
@property (nonatomic,copy)      NSString    *linkAddress;               //默认link地址
@property (nonatomic,copy)      NSString    *nosUploadAddress;          //默认NOS 上传地址
@property (nonatomic,copy)      NSString    *nosDownloadAddress;        //默认NOS 下载地址 (用于拼装URL)
@property (nonatomic,copy)      NSString    *rsaPublicKeyModule;        //RSA 公钥模
@property (nonatomic,assign)    NSInteger   rsaVersion;                 //RSA 公钥版本号

- (void)update:(YSF_NIMServerSetting *)setting;

@end

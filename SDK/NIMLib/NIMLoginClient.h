//
//  YSF_NIMLoginClient.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  登录的设备枚举
 */
typedef NS_ENUM(NSInteger, YSF_NIMLoginClientType){
    /**
     *  Android
     */
    YSF_NIMLoginClientTypeAOS         = 1,
    /**
     *  iOS
     */
    YSF_NIMLoginClientTypeiOS         = 2,
    /**
     *  PC
     */
    YSF_NIMLoginClientTypePC          = 4,
    /**
     *  WEB
     */
    YSF_NIMLoginClientTypeWeb         = 16,
    /**
     *  REST API
     */
    YSF_NIMLoginClientTypeRest        = 32,
};


/**
 *  登录客户端描述
 */
@interface YSF_NIMLoginClient : NSObject
/**
 *  类型
 */
@property (nonatomic,assign,readonly)   YSF_NIMLoginClientType      type;
/**
 *  操作系统
 */
@property (nonatomic,copy,readonly)     NSString                *os;
/**
 *  登录时间
 */
@property (nonatomic,assign,readonly)   NSTimeInterval          timestamp;
@end

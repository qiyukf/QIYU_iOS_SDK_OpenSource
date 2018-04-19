//
//  YSFQuickReply.h
//  NIMLib
//
//  Created by Jacky Yu on 2018/3/6.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSFQuickReply : NSObject

@property (nonatomic, assign) int64_t  serialID;

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *keyword;          //关键字
@property (nonatomic, copy) NSString *content;          //回复内容,包含了web标签
@property (nonatomic, assign) NSInteger categoryId;     //分类id
@property (nonatomic, assign) NSInteger type;           //分类 1 个人库， 0 公共库
@property (nonatomic, assign) BOOL isContentRich;       //内容是否为富文本，0-纯文本、1-富文本
@property (nonatomic, copy) NSString *showContent;      //剔除web标签后的文本内容


@end

//
//  YSFProductInfoShow.h
//  YSFSessionViewController
//
//  Created by JackyYu on 16/5/25.
//  Copyright © 2016年 Netease. All rights reserved.
//



@interface YSFCommodityInfoShow : NSObject<YSF_NIMCustomAttachment>

//命令
@property (nonatomic, assign) NSInteger command;
//标题
@property (nonatomic, copy) NSString *title;
//摘要
@property (nonatomic, copy) NSString *desc;
//图片文件链接
@property (nonatomic, copy) NSString *pictureUrlString;
//跳转链接
@property (nonatomic, copy) NSString *urlString;
//备注
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *userData;
//发送时是否显示
@property (nonatomic, assign) BOOL show;

+ (YSFCommodityInfoShow *)objectByDict:(NSDictionary *)dict;


@end

//
//  YSFEmoticonData.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YSFEmoticonType) {
    YSFEmoticonTypeNone = 0,     //无
    YSFEmoticonTypeDefaultEmoji, //默认emoji
    YSFEmoticonTypeCustomEmoji,  //自定义emoji
    YSFEmoticonTypeCustomGraph,  //自定义图片
    YSFEmoticonTypeDelete,       //删除按钮
};


/**
 * 单个表情数据
 */
@interface YSFEmoticonItem : NSObject

@property (nonatomic, assign) YSFEmoticonType type;
@property (nonatomic, copy) NSString *emoticonID;  //默认emoji为“emoticon_emoji_xx”；自定义emoji/表情为“xxx”
@property (nonatomic, copy) NSString *emoticonTag; //映射字符串，只有emoji类型才有，比如：[可爱]、[大笑]
@property (nonatomic, copy) NSString *fileName;     //文件名
@property (nonatomic, copy) NSString *filePath;     //文件路径，只有默认emoji才有
@property (nonatomic, copy) NSString *fileURL;      //下载路径，只有自定义emoji/表情才有

+ (instancetype)dataByJson:(NSDictionary *)dict;
+ (instancetype)defaultDataByDict:(NSDictionary *)dict prePath:(NSString *)prePath;
- (NSDictionary *)toDict;

@end


/**
 * 表情包数据
 */
@interface YSFEmoticonPackage : NSObject

@property (nonatomic, assign) YSFEmoticonType type;
@property (nonatomic, assign) NSInteger packageID;  //包ID
@property (nonatomic, copy) NSString *packageName;  //包名
@property (nonatomic, copy) NSString *coverNormalName;  //封面图名称-normal
@property (nonatomic, copy) NSString *coverPressName;   //封面图名称-press
@property (nonatomic, copy) NSString *coverURL;         //封面图url
@property (nonatomic, assign) NSInteger status;         //状态，1表示开启，0表示关闭
@property (nonatomic, strong) NSMutableArray <YSFEmoticonItem *> *emoticonList;    //emoji/表情列表数据

+ (instancetype)dataByJson:(NSDictionary *)dict
            defaultPackage:(YSFEmoticonPackage *)defaultPackage
            customEmojiMap:(NSDictionary *)customEmojiMap
              saveEmojiMap:(NSMutableDictionary *)saveEmojiMap;

@end


/**
 * 表情包布局数据
 */
@interface YSFEmoticonLayout : NSObject

@property (nonatomic, assign) NSUInteger itemCount; //表情包内表情数量
@property (nonatomic, assign) NSUInteger rows;      //行数
@property (nonatomic, assign) NSUInteger columns;   //列数
@property (nonatomic, assign) NSUInteger itemInPage;//每页个数
@property (nonatomic, assign) NSUInteger pageCount; //页数
@property (nonatomic, assign) CGFloat itemWidth;    //表情宽度
@property (nonatomic, assign) CGFloat itemHeight;   //表情高度
@property (nonatomic, assign) UIEdgeInsets margin;  //边距

@end


NS_ASSUME_NONNULL_END

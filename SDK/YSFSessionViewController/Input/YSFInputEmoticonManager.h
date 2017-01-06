//
//  YSFEmoticonManager
//  NIM
//
//  Created by amao on 7/2/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//


@interface YSFInputEmoticon : NSObject
@property (nonatomic,strong)    NSString    *emoticonID;
@property (nonatomic,strong)    NSString    *tag;
@property (nonatomic,strong)    NSString    *filename;
@end

@interface YSFInputEmoticonLayout : NSObject
@property (nonatomic, assign) NSInteger rows;               //行数
@property (nonatomic, assign) NSInteger columes;            //列数
@property (nonatomic, assign) NSInteger itemCountInPage;    //每页显示几项
@property (nonatomic, assign) CGFloat   cellWidth;          //单个单元格宽
@property (nonatomic, assign) CGFloat   cellHeight;         //单个单元格高
@property (nonatomic, assign) CGFloat   imageWidth;         //显示图片的宽
@property (nonatomic, assign) CGFloat   imageHeight;        //显示图片的高
@property (nonatomic, assign) BOOL      emoji;

- (id)initEmojiLayout:(CGFloat)width;

- (id)initCharletLayout:(CGFloat)width;

@end

@interface YSFInputEmoticonCatalog : NSObject
@property (nonatomic,strong)    YSFInputEmoticonLayout *layout;
@property (nonatomic,strong)    NSString        *catalogID;
@property (nonatomic,strong)    NSString        *title;
@property (nonatomic,strong)    NSDictionary    *id2Emoticons;
@property (nonatomic,strong)    NSDictionary    *tag2Emoticons;
@property (nonatomic,strong)    NSArray         *emoticons;
@property (nonatomic,strong)    NSString        *icon;             //图标
@property (nonatomic,strong)    NSString        *iconPressed;      //小图标按下效果
@property (nonatomic,assign)    NSInteger       pagesCount;        //分页数
@end

@interface YSFInputEmoticonManager : NSObject
+ (instancetype)sharedManager;

- (YSFInputEmoticonCatalog *)emoticonCatalog:(NSString *)catalogID;
- (YSFInputEmoticon *)emoticonByTag:(NSString *)tag;
- (YSFInputEmoticon *)emoticonByID:(NSString *)emoticonID;
- (YSFInputEmoticon *)emoticonByCatalogID:(NSString *)catalogID
                           emoticonID:(NSString *)emoticonID;

- (NSArray *)loadChartletEmoticonCatalog;
@end

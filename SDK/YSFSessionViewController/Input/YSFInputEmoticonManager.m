//
//  YSFEmoticonManager.h
//  NIM
//
//  Created by amao on 7/2/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonDefine.h"
#import "YSFKit.h"

@implementation YSFInputEmoticon
@end

@implementation YSFInputEmoticonCatalog
@end

@implementation YSFInputEmoticonLayout

- (id)initEmojiLayout:(CGFloat)width
{
    self = [super init];
    if (self)
    {
        _rows            = YSFKit_EmojRows;
        _columes         = ((width - YSFKit_EmojiLeftMargin - YSFKit_EmojiRightMargin) / YSFKit_EmojImageWidth);
        _itemCountInPage = _rows * _columes -1;
        _cellWidth       = (width - YSFKit_EmojiLeftMargin - YSFKit_EmojiRightMargin) / _columes;
        _cellHeight      = YSFKit_EmojCellHeight;
        _imageWidth      = YSFKit_EmojImageWidth;
        _imageHeight     = YSFKit_EmojImageHeight;
        _emoji           = YES;
    }
    return self;
}

- (id)initCharletLayout:(CGFloat)width{
    self = [super init];
    if (self)
    {
        _rows            = YSFKit_PicRows;
        _columes         = ((width - YSFKit_EmojiLeftMargin - YSFKit_EmojiRightMargin) / YSFKit_PicImageWidth);
        _itemCountInPage = _rows * _columes;
        _cellWidth       = (width - YSFKit_EmojiLeftMargin - YSFKit_EmojiRightMargin) / _columes;
        _cellHeight      = YSFKit_PicCellHeight;
        _imageWidth      = YSFKit_PicImageWidth;
        _imageHeight     = YSFKit_PicImageHeight;
        _emoji           = NO;
    }
    return self;
}

@end

@interface YSFInputEmoticonManager ()
@property (nonatomic,strong)    NSArray *catalogs;
@end

@implementation YSFInputEmoticonManager
+ (instancetype)sharedManager
{
    static YSFInputEmoticonManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSFInputEmoticonManager alloc]init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        [self parsePlist];
    }
    return self;
}

- (YSFInputEmoticonCatalog *)emoticonCatalog:(NSString *)catalogID
{
    for (YSFInputEmoticonCatalog *catalog in _catalogs)
    {
        if ([catalog.catalogID isEqualToString:catalogID])
        {
            return catalog;
        }
    }
    return nil;
}


- (YSFInputEmoticon *)emoticonByTag:(NSString *)tag
{
    YSFInputEmoticon *emoticon = nil;
    if ([tag length])
    {
        for (YSFInputEmoticonCatalog *catalog in _catalogs)
        {
            emoticon = [catalog.tag2Emoticons objectForKey:tag];
            if (emoticon)
            {
                break;
            }
        }
    }
    return emoticon;
}


- (YSFInputEmoticon *)emoticonByID:(NSString *)emoticonID
{
    YSFInputEmoticon *emoticon = nil;
    if ([emoticonID length])
    {
        for (YSFInputEmoticonCatalog *catalog in _catalogs)
        {
            emoticon = [catalog.id2Emoticons objectForKey:emoticonID];
            if (emoticon)
            {
                break;
            }
        }
    }
    return emoticon;
}

- (YSFInputEmoticon *)emoticonByCatalogID:(NSString *)catalogID
                           emoticonID:(NSString *)emoticonID
{
    YSFInputEmoticon *emoticon = nil;
    if ([emoticonID length] && [catalogID length])
    {
        for (YSFInputEmoticonCatalog *catalog in _catalogs)
        {
            if ([catalog.catalogID isEqualToString:catalogID])
            {
                emoticon = [catalog.id2Emoticons objectForKey:emoticonID];
                break;
            }
        }
    }
    return emoticon;
}



- (NSArray *)loadChartletEmoticonCatalog{
    NSString *directory = [YSFKit_EmoticonPath stringByAppendingPathComponent:YSFKit_ChartletChartletCatalogPath];
    NSURL *url = [[NSBundle mainBundle] URLForResource:[[YSFKit sharedKit] bundleName]
                                         withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:url];    
    NSArray  *paths   = [bundle pathsForResourcesOfType:nil inDirectory:directory];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            YSFInputEmoticonCatalog *catalog = [[YSFInputEmoticonCatalog alloc]init];
            catalog.catalogID = path.lastPathComponent;
            NSArray *resources = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:YSFKit_ChartletChartletCatalogContentPath]];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *path in resources) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension;
                YSFInputEmoticon *icon  = [[YSFInputEmoticon alloc] init];
                icon.emoticonID = name.ysf_stringByDeletingPictureResolution;
                icon.filename   = path;
                [array addObject:icon];
            }
            catalog.emoticons = array;
            
            NSArray *icons     = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:YSFKit_ChartletChartletCatalogIconPath]];
            for (NSString *path in icons) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension.ysf_stringByDeletingPictureResolution;
                if ([name hasSuffix:YSFKit_ChartletChartletCatalogIconsSuffixNormal]) {
                    catalog.icon = path;
                }else if([name hasSuffix:YSFKit_ChartletChartletCatalogIconsSuffixHighLight]){
                    catalog.iconPressed = path;
                }
            }
            [res addObject:catalog];
        }
    }
    return res;
}

- (void)parsePlist
{
    NSMutableArray *catalogs = [NSMutableArray array];
    NSString *directory = [YSFKit_EmoticonPath stringByAppendingPathComponent:YSFKit_EmojiPath];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:[[YSFKit sharedKit] bundleName]
                                         withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    
    NSString *filepath = [bundle pathForResource:@"emoji" ofType:@"plist" inDirectory:directory];
    if (filepath) {
        NSArray *array = [NSArray arrayWithContentsOfFile:filepath];
        for (NSDictionary *dict in array)
        {
            NSDictionary *info = dict[@"info"];
            NSArray *emoticons = dict[@"data"];
            
            YSFInputEmoticonCatalog *catalog = [self catalogByInfo:info
                                                     emoticons:emoticons];
            [catalogs addObject:catalog];
        }
    }
    _catalogs = catalogs;
}

- (YSFInputEmoticonCatalog *)catalogByInfo:(NSDictionary *)info
                             emoticons:(NSArray *)emoticonsArray
{
    YSFInputEmoticonCatalog *catalog = [[YSFInputEmoticonCatalog alloc]init];
    catalog.catalogID   = info[@"id"];
    catalog.title       = info[@"title"];
    NSString *iconNamePrefix = [[[[YSFKit sharedKit] bundleName] stringByAppendingPathComponent:YSFKit_EmoticonPath] stringByAppendingPathComponent:YSFKit_EmojiPath];
    NSString *icon      = info[@"normal"];
    catalog.icon = [iconNamePrefix stringByAppendingPathComponent:icon];
    NSString *iconPressed = info[@"pressed"];
    catalog.iconPressed = [iconNamePrefix stringByAppendingPathComponent:iconPressed];

    
    NSMutableDictionary *tag2Emoticons = [NSMutableDictionary dictionary];
    NSMutableDictionary *id2Emoticons = [NSMutableDictionary dictionary];
    NSMutableArray *emoticons = [NSMutableArray array];
    
    for (NSDictionary *emoticonDict in emoticonsArray) {
        YSFInputEmoticon *emoticon  = [[YSFInputEmoticon alloc] init];
        emoticon.emoticonID     = emoticonDict[@"id"];
        emoticon.tag            = emoticonDict[@"tag"];
        NSString *fileName      = emoticonDict[@"file"];
        NSString *imageNamePrefix = [[[[YSFKit sharedKit] bundleName] stringByAppendingPathComponent:YSFKit_EmoticonPath] stringByAppendingPathComponent:YSFKit_EmojiPath];
        emoticon.filename = [imageNamePrefix stringByAppendingPathComponent:fileName];
        if (emoticon.emoticonID) {
            [emoticons addObject:emoticon];
            id2Emoticons[emoticon.emoticonID] = emoticon;
        }
        if (emoticon.tag) {
            tag2Emoticons[emoticon.tag] = emoticon;
        }
    }
    
    catalog.emoticons       = emoticons;
    catalog.id2Emoticons    = id2Emoticons;
    catalog.tag2Emoticons   = tag2Emoticons;
    return catalog;
}


@end

//
//  YSFEmoticonData.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonData.h"
#import "YSFApiDefines.h"
#import "YSFEmoticonDataManager.h"


@implementation YSFEmoticonItem
+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFEmoticonItem *item = [[YSFEmoticonItem alloc] init];
    item.emoticonID = [dict ysf_jsonString:YSFApiKeyId];
    item.type = [dict ysf_jsonInteger:YSFApiKeyType];
    item.emoticonTag = [dict ysf_jsonString:YSFApiKeyEmoticonTag];
    item.fileName = [dict ysf_jsonString:YSFApiKeyEmoticonFile];
    if (!item.fileName.length) {
        item.fileName = [dict ysf_jsonString:YSFApiKeyEmoticonName];
    }
    item.fileURL = [dict ysf_jsonString:YSFApiKeyUrl];
    if (!item.fileURL.length) {
        item.fileURL = [dict ysf_jsonString:YSFApiKeyEmoticonURL];
    }
    item.filePath = [dict ysf_jsonString:YSFApiKeyEmoticonPath];
    return item;
}

+ (instancetype)defaultDataByDict:(NSDictionary *)dict prePath:(NSString *)prePath {
    YSFEmoticonItem *item = [[YSFEmoticonItem alloc] init];
    item.type = YSFEmoticonTypeDefaultEmoji;
    item.emoticonID = [dict ysf_jsonString:YSFApiKeyId];
    item.emoticonTag = [dict ysf_jsonString:YSFApiKeyEmoticonTag];
    item.fileName = [dict ysf_jsonString:YSFApiKeyEmoticonFile];
    item.filePath = [prePath stringByAppendingPathComponent:item.fileName];
    return item;
}

- (NSDictionary *)toDict {
    return @{
             YSFApiKeyId : YSFStrParam(self.emoticonID),
             YSFApiKeyType : @(self.type),
             YSFApiKeyEmoticonTag : YSFStrParam(self.emoticonTag),
             YSFApiKeyEmoticonFile : YSFStrParam(self.fileName),
             YSFApiKeyEmoticonPath : YSFStrParam(self.filePath),
             YSFApiKeyUrl : YSFStrParam(self.fileURL),
             };
}

@end

@implementation YSFEmoticonPackage
+ (instancetype)dataByJson:(NSDictionary *)dict
            defaultPackage:(YSFEmoticonPackage *)defaultPackage
            customEmojiMap:(NSDictionary *)customEmojiMap
              saveEmojiMap:(NSMutableDictionary *)saveEmojiMap {
    YSFEmoticonPackage *package = [[YSFEmoticonPackage alloc] init];
    package.packageID = [dict ysf_jsonInteger:YSFApiKeyId];
    package.packageName = [dict ysf_jsonString:YSFApiKeyEmoticonPackageName];
    package.coverNormalName = [dict ysf_jsonString:YSFApiKeyEmoticonPackageCoverName];
    package.coverURL = [dict ysf_jsonString:YSFApiKeyEmoticonPackageCoverURL];
    package.status = [dict ysf_jsonInteger:YSFApiKeyStatus];
    if (package.status == 0) {
        return nil;
    }
    if (package.packageID == -1) {
        package.type = YSFEmoticonTypeDefaultEmoji;
    } else {
        NSInteger type = [dict ysf_jsonInteger:YSFApiKeyEmoticonPackageType];
        if (type == 1) {
            package.type = YSFEmoticonTypeCustomGraph;
        } else if (type == 2) {
            package.type = YSFEmoticonTypeCustomEmoji;
        } else {
            package.type = YSFEmoticonTypeNone;
        }
    }
    
    if (package.type == YSFEmoticonTypeDefaultEmoji) {
        defaultPackage = package;
        return defaultPackage;
    } else if (package.type == YSFEmoticonTypeCustomEmoji || package.type == YSFEmoticonTypeCustomGraph) {
        NSArray *data = [dict ysf_jsonArray:YSFApiKeyEmoticonPackageList];
        if (data && [data count]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *itemDict in data) {
                YSFEmoticonItem *item = [YSFEmoticonItem dataByJson:itemDict];
                item.type = package.type;
                if (item.type == YSFEmoticonTypeCustomEmoji && [customEmojiMap count]) {
                    NSDictionary *mapDict = [customEmojiMap objectForKey:item.emoticonID];
                    if ([mapDict count]) {
                        item.emoticonTag = [mapDict ysf_jsonString:YSFApiKeyEmoticonTag];
                        if (item.emoticonTag.length) {
                            [saveEmojiMap setValue:item forKey:item.emoticonTag];
                            [[YSFEmoticonDataManager sharedManager] saveDict:[item toDict] forKey:item.emoticonTag];
                        }
                    }
                }
                [array addObject:item];
            }
            package.emoticonList = array;
        }
    }
    return package;
}

- (id)copy {
    YSFEmoticonPackage *package = [[YSFEmoticonPackage alloc] init];
    package.type = self.type;
    package.packageID = self.packageID;
    package.packageName = self.packageName;
    package.coverNormalName = self.coverNormalName;
    package.coverPressName = self.coverPressName;
    package.coverURL = self.coverURL;
    package.status = self.status;
    if (self.emoticonList) {
        package.emoticonList = [NSMutableArray arrayWithArray:self.emoticonList];
    }
    return package;
}

@end


@implementation YSFEmoticonLayout
@end

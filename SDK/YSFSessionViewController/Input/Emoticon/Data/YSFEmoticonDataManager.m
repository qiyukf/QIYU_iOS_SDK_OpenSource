//
//  YSFEmoticonDataManager.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonDataManager.h"
#import "YSFKit.h"
#import "YSFKeyValueStore.h"
#import "YSFApiDefines.h"
#import "YSFEmoticonListRequest.h"
#import "YSFEmoticonMapRequest.h"


@interface YSFEmoticonDataManager ()

@property (nonatomic, strong) YSFKeyValueStore *store;
@property (nonatomic, strong) YSFEmoticonPackage *defEmojiPackage;
@property (nonatomic, strong) NSMutableDictionary *customEmojiMap; //映射关系：id->dict(id+tag+url)

@property (nonatomic, assign) BOOL isRequestMap;
@property (nonatomic, assign) BOOL isRequestList;

@end


@implementation YSFEmoticonDataManager
+ (instancetype)sharedManager {
    static YSFEmoticonDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[YSFEmoticonDataManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _needRequest = YES;
        _packageList = [NSMutableArray array];
        _emojiMap = [NSMutableDictionary dictionary];
        
        _isRequestMap = NO;
        _isRequestList = NO;
        
        [self loadDefaultEmojiPackage];
    }
    return self;
}

- (void)onlyloadDefaultEmojiData {
    [self.packageList removeAllObjects];
    if (self.defEmojiPackage) {
        [self.packageList addObject:self.defEmojiPackage];
    }
}

#pragma mark - Data Request
- (void)requestEmoticonDataCompletion:(YSFEmoticonCompletion)completion {
    if (_needRequest) {
        //1.先请求map数据拿到映射关系，此处超时时间设置较短
        __weak typeof(self) weakSelf = self;
        [self requestEmoticonMapTimeoutInterval:5.0 completion:^(NSError * _Nonnull error) {
            //2.后请求list数据，并填充map数据
            [weakSelf requestEmoticonListTimeoutInterval:10.0 completion:^(NSError * _Nonnull error) {
                if (!error) {
                    weakSelf.needRequest = NO;
                }
                if (completion) {
                    completion(error);
                }
            }];
        }];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

- (void)requestEmoticonListTimeoutInterval:(NSTimeInterval)timeoutInterval
                                completion:(YSFEmoticonCompletion)completion {
    if (_isRequestList) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:YSFErrorDomain code:0 userInfo:nil];
            completion(error);
        }
        return;
    }
    _isRequestList = YES;
    YSFEmoticonListRequest *request = [[YSFEmoticonListRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi get:request timeoutInterval:timeoutInterval completion:^(NSError *error, id returendObject) {
        weakSelf.isRequestList = NO;
        if (!error && [returendObject isKindOfClass:[NSArray class]]) {
            [weakSelf.packageList removeAllObjects];
            [weakSelf.emojiMap removeAllObjects];
            for (NSDictionary *dict in returendObject) {
                YSFEmoticonPackage *package = [YSFEmoticonPackage dataByJson:dict
                                                              defaultPackage:weakSelf.defEmojiPackage
                                                              customEmojiMap:weakSelf.customEmojiMap
                                                                saveEmojiMap:weakSelf.emojiMap];
                if (package.type == YSFEmoticonTypeDefaultEmoji) {
                    [weakSelf loadDefaultEmojiDataForPackage:package];
                }
                if ([package.emoticonList count]) {
                    [weakSelf.packageList addObject:package];
                }
            }
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)loadDefaultEmojiPackage {
    if (!self.defEmojiPackage) {
        self.defEmojiPackage = [[YSFEmoticonPackage alloc] init];
        self.defEmojiPackage.type = YSFEmoticonTypeDefaultEmoji;
        [self loadDefaultEmojiDataForPackage:self.defEmojiPackage];
    }
}

- (void)loadDefaultEmojiDataForPackage:(YSFEmoticonPackage *)package {
    self.emojiPath = [NSString stringWithFormat:@"%@/%@/%@", [[YSFKit sharedKit] bundleName], YSFEmoticon_EmoticonPath, YSFEmoticon_EmojiPath];
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:[[YSFKit sharedKit] bundleName] withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSString *directory = [YSFEmoticon_EmoticonPath stringByAppendingPathComponent:YSFEmoticon_EmojiPath];
    NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist" inDirectory:directory];
    if ([path length]) {
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        if (array && [array count]) {
            NSDictionary *dict = [array firstObject];
            NSString *prefix = self.emojiPath;
            NSDictionary *info = [dict ysf_jsonDict:@"info"];
            NSString *normal = [info ysf_jsonString:@"normal"];
            package.coverNormalName = [prefix stringByAppendingPathComponent:normal];
            NSString *pressed = [info ysf_jsonString:@"pressed"];
            package.coverPressName = [prefix stringByAppendingPathComponent:pressed];
            
            NSArray *data = [dict ysf_jsonArray:@"data"];
            NSMutableArray *emojiArray = [NSMutableArray array];
            for (NSDictionary *emojiDict in data) {
                YSFEmoticonItem *item = [YSFEmoticonItem defaultDataByDict:emojiDict prePath:prefix];
                if (item.emoticonTag.length) {
                    [self.emojiMap setValue:item forKey:item.emoticonTag];
                    [self saveDict:[item toDict] forKey:item.emoticonTag];
                }
                [emojiArray addObject:item];
            }
            package.emoticonList = emojiArray;
        }
    }
}

- (void)requestEmoticonMapTimeoutInterval:(NSTimeInterval)timeoutInterval
                               completion:(YSFEmoticonCompletion)completion {
    if (_isRequestMap) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:YSFErrorDomain code:0 userInfo:nil];
            completion(error);
        }
        return;
    }
    _isRequestMap = YES;
    YSFEmoticonMapRequest *request = [[YSFEmoticonMapRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi get:request timeoutInterval:timeoutInterval completion:^(NSError *error, id returendObject) {
        weakSelf.isRequestMap = NO;
        if (!error && [returendObject isKindOfClass:[NSArray class]]) {
            if (!weakSelf.customEmojiMap) {
                weakSelf.customEmojiMap = [NSMutableDictionary dictionary];
            }
            if (!weakSelf.emojiMap) {
                weakSelf.emojiMap = [NSMutableDictionary dictionary];
            }
            for (NSDictionary *dict in returendObject) {
                NSString *emojiID = [dict ysf_jsonString:YSFApiKeyId];
                NSString *tag = [dict ysf_jsonString:YSFApiKeyEmoticonTag];
                if ([emojiID length]) {
                    [weakSelf.customEmojiMap setValue:dict forKey:emojiID];
                }
                if ([tag length]) {
                    YSFEmoticonItem *item = [YSFEmoticonItem dataByJson:dict];
                    item.type = YSFEmoticonTypeCustomEmoji;
                    [weakSelf.emojiMap setValue:item forKey:tag];
                    [weakSelf saveDict:[item toDict] forKey:item.emoticonTag];
                }
            }
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (YSFEmoticonItem *)emoticonItemForTag:(NSString *)tag {
    if ([tag length]) {
        id value = [self.emojiMap valueForKey:tag];
        if ([value isKindOfClass:[YSFEmoticonItem class]]) {
            return value;
        }
        //若map没有，则从DB中找
        value = [self dictByKey:tag];
        if (value) {
            return [YSFEmoticonItem dataByJson:value];
        }
    }
    return nil;
}

- (NSString *)emoticonTagForID:(NSString *)emoticonID {
    if (emoticonID.length) {
        NSDictionary *dict = [self.customEmojiMap valueForKey:emoticonID];
        if (dict) {
            NSString *tag = [dict ysf_jsonString:YSFApiKeyEmoticonTag];
            return tag;
        }
    }
    return nil;
}

#pragma mark - 持久化
- (YSFKeyValueStore *)store {
    if (!_store) {
        if ([_emoticonRootPath length]) {
            NSString *storePath = [_emoticonRootPath stringByAppendingPathComponent:@"emoticonDB.db"];
            _store = [YSFKeyValueStore storeByPath:storePath];
        }
    }
    return _store;
}

- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error) {
            YSFLogErr(@"save dict %@ failed", dict);
        }
        if (data) {
            [self.store saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:key];
        }
    }
}

- (void)saveArray:(NSArray *)array forKey:(NSString *)key {
    if ([array isKindOfClass:[NSArray class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error) {
            YSFLogErr(@"save dict %@ failed",array);
        }
        if (data) {
            [self.store saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:key];
        }
    }
}

- (NSDictionary *)dictByKey:(NSString *)key {
    NSDictionary *dict = nil;
    NSString *value = [self.store valueByKey:key];
    if (value) {
        dict = [value ysf_toDict];
    }
    return dict;
}

- (NSArray *)arrayByKey:(NSString *)key {
    NSArray *array = nil;
    NSString *value = [self.store valueByKey:key];
    if (value) {
        array = [value ysf_toArray];
    }
    return array;
}

@end

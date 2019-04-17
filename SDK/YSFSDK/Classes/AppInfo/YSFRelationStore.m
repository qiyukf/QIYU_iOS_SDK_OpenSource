//
//  YSFRelationStore.m
//  YSFSDK
//
//  Created by amao on 9/9/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFRelationStore.h"
#import "YSFKeyValueStore.h"
#import "QYSDK_Private.h"


@interface YSFRelationStore ()

@property (nonatomic, strong) YSFKeyValueStore *store;

@end


@implementation YSFRelationStore
- (instancetype)init {
    if (self = [super init]) {
        NSString *path = [[[[QYSDK sharedSDK] pathManager] sdkGlobalPath] stringByAppendingPathComponent:@"id_ysf.db"];
        _store = [YSFKeyValueStore storeByPath:path];
    }
    return self;
}

- (void)mapYsf:(NSString *)accid toUser:(NSString *)foreignId {
    if (accid && foreignId) {
        NSString *oldAccid = [_store valueByKey:foreignId];
        //如果老数据foreignId对应的数据和当前的accid 不同，做一次消息数据的迁移...我觉得这是还是很蛋疼的
        if (oldAccid&& ![oldAccid isEqualToString:accid]) {
            YSFLogApp(@"migrate from %@ to %@",oldAccid,accid);
            [[[YSF_NIMSDK sharedSDK] conversationManager] migrateFrom:oldAccid completion:^(NSError *error) {
                YSFLogApp(@"%@",error);
            }];
        }
        [_store saveValue:accid forKey:foreignId];
    }
}
         
@end

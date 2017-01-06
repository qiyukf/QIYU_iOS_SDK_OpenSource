//
//  YSFRelationStore.h
//  YSFSDK
//
//  Created by amao on 9/9/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


@interface YSFRelationStore : NSObject
- (void)mapYsf:(NSString *)accid
        toUser:(NSString *)foreignId;
@end

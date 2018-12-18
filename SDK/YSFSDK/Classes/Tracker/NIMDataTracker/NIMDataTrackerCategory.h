//
//  NIMDataTrackerCategory.h
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//



@interface NSMutableDictionary (YSF_NIMDataTracker)
- (void)ysfdt_setObject:(id)object
                 forKey:(NSString *)key;
@end

@interface NSDictionary (YSF_NIMDataTracker)
- (BOOL)ysfdt_jsonBool:(id)key;
- (long long)ysfdt_jsonLongLong: (id)key;
@end

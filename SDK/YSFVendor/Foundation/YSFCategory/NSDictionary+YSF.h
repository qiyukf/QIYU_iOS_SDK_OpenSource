//
//  NSDictionary+YSF.h
//  YSFSDK
//
//  Created by amao on 8/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YSF)
- (NSData *)ysf_postParam;

- (NSString *)ysf_getParam;

- (NSDictionary *)ysf_formattedDict;

- (NSString *)ysf_toUTF8String;

- (NSString *)ysf_jsonString: (NSString *)key;

- (NSDictionary *)ysf_jsonDict: (NSString *)key;
- (NSArray *)ysf_jsonArray: (NSString *)key;
- (NSArray *)ysf_jsonStringArray: (NSString *)key;


- (BOOL)ysf_jsonBool: (NSString *)key;
- (NSInteger)ysf_jsonInteger: (NSString *)key;
- (long long)ysf_jsonLongLong: (NSString *)key;
- (unsigned long long)ysf_jsonUnsignedLongLong:(NSString *)key;

- (double)ysf_jsonDouble: (NSString *)key;

@end

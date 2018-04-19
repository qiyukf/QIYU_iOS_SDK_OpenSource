//
//  NSString+YSF.h
//  YSFSDK
//
//  Created by amao on 8/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (YSF)

- (NSString *)unescapeHtml;

- (NSString *)ysf_md5;

- (NSString *)ysf_StringByAppendingApiPath:(NSString *)apiPath;

- (NSString *)ysf_urlEncodedString;

- (NSString *)ysf_stringByDeletingPictureResolution;

- (NSString *)ysf_formattedURLString;

- (NSDictionary *)ysf_paramsFromString;

- (CGSize)ysf_stringSizeWithFont:(UIFont *)font;

- (NSDictionary *)ysf_toDict;

- (NSArray *)ysf_toArray;

- (NSString *)ysf_trim;

- (NSString *)ysf_https;


- (NSString *)ysf_stringByAppendExt:(NSString *)ext;


//判断是否为纯整形
- (BOOL)ysf_isPureInteger;

//判断是否为浮点形：
- (BOOL)ysf_isPureFloat;

- (NSString *)ysf_urlEncodeString;

- (NSString *)ysf_urlDecodeString;

//字符串剔除重复的空格和回车换行
- (NSString*)ysf_stringByRemoveRepeatedWhitespaceAndNewline;

@end

//
//  NSBundle+MJRefresh.h
//  MJRefreshExample
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (YSFRefresh)
+ (instancetype)ysf_refreshBundle;
+ (UIImage *)ysf_arrowImage;
+ (NSString *)ysf_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)ysf_localizedStringForKey:(NSString *)key;
@end

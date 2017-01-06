//
//  NSString+Regex.m
//  YSFSDK
//
//  Created by 金华 on 16/3/10.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)

- (BOOL)matchEmailFormat{
    NSString* mailRegexStr = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mailRegexStr];
    return [emailTest evaluateWithObject:self];
}
@end

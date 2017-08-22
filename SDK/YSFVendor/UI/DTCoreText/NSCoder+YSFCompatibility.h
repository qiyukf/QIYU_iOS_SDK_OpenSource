//
//  NSCoder+YSFCompatibility.h
//  YSFCoreText
//
//  Created by Ryan Johnson on 14/02/19.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "YSFCompatibility.h"
#import <UIKit/UIKit.h>


@interface NSCoder (YSFCompatibility)

#if !TARGET_OS_IPHONE
- (void)ysf_encodeCGSize:(CGSize)size forKey:(NSString *)key;
- (CGSize)ysf_decodeCGSizeForKey:(NSString *)key;
#endif

- (void)ysf_encodeDTEdgeInsets:(YSFEdgeInsets)insets forKey:(NSString *)key;
- (YSFEdgeInsets)ysf_decodeDTEdgeInsetsForKey:(NSString *)key;

@end

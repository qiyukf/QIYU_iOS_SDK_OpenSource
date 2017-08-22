//
//  UIFont+YSFCoreText.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 11.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

/**
 Methods to translate from `CTFont` to `UIFont`
 */

@interface UIFont (YSFCoreText)

/**
 Creates a UIFont that matches the provided CTFont.
 @param ctFont a `CTFontRef`
 @returns The matching UIFont
 */
+ (UIFont *)ysf_fontWithCTFont:(CTFontRef)ctFont;

@end

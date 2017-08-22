//
//  YSFCoreTextFunctions.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 21.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "YSFCompatibility.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

/**
 Creates a CTFont from a UIFont
 @param font The `UIFont`
 @returns The matching CTFont
 */
CTFontRef YSFCTFontCreateWithUIFont(UIFont *font);
#endif

/**
 Converts an NSLineBreakMode into CoreText line truncation type
 */
CTLineTruncationType YSFCTLineTruncationTypeFromNSLineBreakMode(NSLineBreakMode lineBreakMode);

/**
 Rounds the passed value according to the specified content scale.
 
 With contentScale 1 the results are identical to roundf, with Retina content scale 2 the results are multiples of 0.5.
 */
CGFloat YSFRoundWithContentScale(CGFloat value, CGFloat contentScale);

/**
 Rounds up the passed value according to the specified content scale.
 
 With contentScale 1 the results are identical to roundf, with Retina content scale 2 the results are multiples of 0.5.
 */
CGFloat YSFCeilWithContentScale(CGFloat value, CGFloat contentScale);

/**
 Rounds down the passed value according to the sspecifiedcontent scale.
 
 With contentScale 1 the results are identical to roundf, with Retina content scale 2 the results are multiples of 0.5.
 */
CGFloat YSFFloorWithContentScale(CGFloat value, CGFloat contentScale);

#pragma mark - Alignment Conversion

#if YSFCORETEXT_SUPPORT_NS_ATTRIBUTES
/**
 Converts from NSTextAlignment to CTTextAligment
 */
CTTextAlignment YSFNSTextAlignmentToCTTextAlignment(NSTextAlignment nsTextAlignment);

/**
 Converts from CTTextAlignment to NSTextAligment
 */
NSTextAlignment YSFNSTextAlignmentFromCTTextAlignment(CTTextAlignment ctTextAlignment);
#endif


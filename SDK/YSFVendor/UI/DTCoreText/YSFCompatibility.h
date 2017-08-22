//
//  YSFCompatibility.h
//  YSFCoreText
//
//  Created by Oliver Letterer on 09.04.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#pragma mark - iOS

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

	// Compatibility Aliases
	#define YSFColor UIColor
	#define YSFImage UIImage
	#define YSFFont UIFont

	// Edge Insets
	#define YSFEdgeInsets UIEdgeInsets
	#define YSFEdgeInsetsMake(top, left, bottom, right) UIEdgeInsetsMake(top, left, bottom, right)

	// NS-style text attributes are possible with iOS SDK 6.0 or higher
	#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
		#define YSFCORETEXT_SUPPORT_NS_ATTRIBUTES 1
	#endif

	// NSParagraphStyle supports tabs as of iOS SDK 7.0 or higher
	#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
		#define YSFCORETEXT_SUPPORT_NSPARAGRAPHSTYLE_TABS 1
	#endif

	// iOS before 5.0 has leak in CoreText replacing attributes
	#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
		#define YSFCORETEXT_NEEDS_ATTRIBUTE_REPLACEMENT_LEAK_FIX 1
	#endif

	// iOS 7 bug (rdar://14684188) workaround, can be removed once this bug is fixed
	#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
		#define YSFCORETEXT_FIX_14684188 1
	#endif

	// use NSURLSession if NSURLConnection is deprecated
	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
		#define YSFCORETEXT_USES_NSURLSESSION 1
	#endif

	// constant for checking for iOS 6
	#define YSFNSFoundationVersionNumber_iOS_6_0  992.00

	// constant for checking for iOS 7
	#define YSFNSFoundationVersionNumber_iOS_7_0  1047.00


	// runtime-check if NS-style attributes are allowed
	static inline BOOL YSFCoreTextModernAttributesPossible()
	{
#if YSFCORETEXT_SUPPORT_NS_ATTRIBUTES
		if (floor(NSFoundationVersionNumber) >= YSFNSFoundationVersionNumber_iOS_6_0)
		{
			return YES;
		}
#endif
		return NO;
	}

	// runtime-check if CoreText draws underlines
	static inline BOOL YSFCoreTextDrawsUnderlinesWithGlyphs()
	{
		if (floor(NSFoundationVersionNumber) >= YSFNSFoundationVersionNumber_iOS_7_0)
		{
			return YES;
		}
	
		return NO;
	}

#if TARGET_CPU_ARM64 || TARGET_CPU_X86_64
	#define YSFNSNumberFromCGFloat(x) [NSNumber numberWithDouble:x]
#else
	#define YSFNSNumberFromCGFloat(x) [NSNumber numberWithFloat:x]
#endif

#endif


#pragma mark - Mac


#if !TARGET_OS_IPHONE

	// Compatibility Aliases
	#define YSFColor NSColor
	#define YSFImage NSImage
	#define YSFFont NSFont

	// Edge Insets
	#define YSFEdgeInsets NSEdgeInsets
	#define YSFEdgeInsetsMake(top, left, bottom, right) NSEdgeInsetsMake(top, left, bottom, right)

	// Mac supports NS-Style Text Attributes since 10.0
	#define YSFCORETEXT_SUPPORT_NS_ATTRIBUTES 1
	#define YSFCORETEXT_SUPPORT_NSPARAGRAPHSTYLE_TABS 1

	// theoretically MacOS before 10.8 might have a leak in CoreText replacing attributes
	#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7
		#define YSFCORETEXT_NEEDS_ATTRIBUTE_REPLACEMENT_LEAK_FIX 1
	#endif

	// use NSURLSession if NSURLConnection is deprecated
	#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_11
	#define YSFCORETEXT_USES_NSURLSESSION 1
	#endif

	// NSValue has sizeValue on Mac, CGSizeValue on iOS
	#define CGSizeValue sizeValue

	// String functions named differently on Mac
	static inline NSString *YSFNSStringFromCGRect(const CGRect rect)
	{
		return NSStringFromRect(NSRectFromCGRect(rect));
	}

	static inline NSString *YSFNSStringFromCGSize(const CGSize size)
	{
		return NSStringFromSize(NSSizeFromCGSize(size));
	}

	static inline NSString *YSFNSStringFromCGPoint(const CGPoint point)
	{
		return NSStringFromPoint(NSPointFromCGPoint(point));
	}

	// runtime-check if NS-style attributes are allowed
	static inline BOOL YSFCoreTextModernAttributesPossible()
	{
		return YES;
	}

	// runtime-check if CoreText draws underlines
	static inline BOOL YSFCoreTextDrawsUnderlinesWithGlyphs()
	{
		return NO;
	}

	#define YSFNSNumberFromCGFloat(x) [NSNumber numberWithDouble:x]
#endif

// this enables generic ceil, floor, abs, round functions that work for 64 and 32 bit
#include <tgmath.h>
